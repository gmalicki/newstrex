class NewsItem
  include DataMapper::Resource
  
  property :id,             Serial  
  property :news_source_id, Integer,   :nullable => false
  property :title,          Text,      :nullable => false,  :lazy => false
  property :url,            Text,      :nullable => false,  :unique => true, :lazy => false
  property :rss_content,    Text,      :lazy => false
  property :deep_content,   Text  
  property :content,        Text,                           :lazy => false
  property :names,          Object
  property :images,         Object,                         :lazy => false
  property :published_at,   DateTime
  property :created_at,     DateTime,                       :lazy => false
  property :updated_at,     DateTime
  
  has n, :news_matches
  has n, :people, :through => :news_matches
  
  belongs_to  :news_source
  
  before   :save do   
    extract_names
    extract_images
    localize_content
  end
  after    :create, :load_matches
    
protected

  def content_plain_text
    PlaintextDoc.new(rss_content).to_s
  end
  
  def localize_content
    self.content = content_plain_text
    self.people.each { |p| self.content.gsub!(p.full_name, link_for_person(p)) }    
  end
  
  def link_for_person(person)
    '<a href="/people/' + person.permlink + '">' + person.full_name + '</a>'
  end
  
  def extract_names
    self.names = GP.parse(content_plain_text)
  end
  
  def extract_images
    begin
      is = ImageSource.new(rss_content, File.join(Merb.root, 'public', 'images') + '/')
      puts "images: #{is.images.inspect}"
      self.images = is.images
    rescue
    end
  end
  
  def load_matches
    NewsMatch.submit_news(self)
  end
end


require 'rubyful_soup'
require 'open-uri'
#require 'image_science'

class ImageSource
  attr_accessor :save_path
  attr_reader   :images
  
  def initialize(html, save_path = '/tmp/')
    #@html, @save_path, @images = html, save_path, download_images
    @html, @save_path = html, save_path
    @images = download_images
  end
  
protected
  def download_images
    # images = []
    #  image_urls.each do |uri|
    #    if img = open(uri, 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)').read
    #      img_type = %w(.jpg .gif .png).detect { |x| x if uri.match(/#{x}/i) }
    #      orig_path = @save_path+Digest::MD5.hexdigest(uri)+'-orig' + img_type
    #      sized_path = @save_path+Digest::MD5.hexdigest(uri) + img_type
    #      open(orig_path, 'wb').write(img)
    #      ImageScience.with_image(orig_path) do |img|
    #        img.thumbnail(100) do |thumb|
    #          thumb.save sized_path
    #        end
    #      end
    #      images << (Digest::MD5.hexdigest(uri)+img_type)
    #    end
    #  end
    #  images
   end
  
  def image_urls
    soup = BeautifulSoup.new(@html)
    soup.find_all('img').map { |img| img['src'] }
  end
end
  

class PlaintextDoc
  def initialize(html)
    @html = html
    @pt = remove_blocked_items(content_plain_text)
  end
  
  def to_s
    @pt
  end
  
protected
  def content_plain_text
    fn = "/tmp/news_item_#{Digest::MD5.hexdigest(@html)}.html"
    File.open(fn, 'w') { |f| f.puts @html }
    text = `lynx -dump file://#{fn}`.split('References')[0].strip
    File.delete(fn)
    text
  end
  
  def remove_blocked_items(str)
    while i = find_block(str)
      str.gsub!("[#{i}]", '')
    end
    str
  end
  
  def find_block(str)
    begin
      if res = str.split('[')[1].split(']')[0]
        return res
      end
    rescue
    end
    nil
  end
end


# In leu of a better Parts Of Speech tagger.  
module Tagthenet
  API_URL = 'http://tagthe.net/api';

  require "net/http"
  require 'rexml/document'
  require 'uri'

  #options is a hash. valid keys are :text and :url.
  #for example: Tagthenet::parse :text => "Hello World!" 
  def self.parse options
    Tagger.new.parse options
  end

  class Tagger
    def parse options
      xml = parse_to_xml(options)
      xml2tags(xml)
    end

  private
    def parse_to_xml options
      options.each{|key,value|options[key] = URI.escape(value);}
      res = Net::HTTP.post_form(URI.parse(API_URL), options);
      res.body
    end

    def xml2tags xml
      tags = Hash.new{|h,k|h[k] = []}
      doc = REXML::Document.new(xml) 
      doc.elements.each("memes/meme/dim") { |dim| 
        type = dim.attributes["type"] 
        doc.elements.each("memes/meme/dim[@type='#{type}']/item") {|item| 
          tags[type] << item.text 
        }
      }
      tags
    end
  end
end


module GP
  def self.parse text
    words      = text.split(' ').map { |w| w.split("'")[0] }
    full_names = Set.new
    words.each_with_index do |w, idx| 
      w1 = words[idx + 1] || " "
      w2 = words[idx + 2] || " "
      if w1.size == 0
        w1 = " "
      end
      if w2.size == 0
        w2 = " "
      end
      if capitalized?(w) && capitalized?(w1) && capitalized?(w2) && !w.match(',') && !w1.match(',') && !w2.match('.')
        full_names << "#{w} #{w1.split(',')[0]} #{w2.split('.')[0].split(',')[0]}"
      elsif capitalized?(w) && capitalized?(words[idx+1]) && !w.match(',')
        full_names << "#{w} #{w1.split(',')[0].split('.')[0]}"
      end
    end
    full_names.to_a.map { |x| x.lstrip.rstrip } 
  end
  
  def self.capitalized?(word)
    return false if word.class != String
    word.gsub(/\b\w/){$&.upcase} == word
  end
end


module CLAWS
  API_URL = "http://lingo.lancs.ac.uk/claws/trial.html"
  
  def self.parse options
    if text = options[:text]
      Tagger.new.parse text
    end
  end
  
  class Tagger
    def parse url
      xml = parse_to_xml(url)
      xml2tags(xml)
    end
  
  private
    def parse_to_xml url
    end
    
    def xml2tags xml
    end
  end
end
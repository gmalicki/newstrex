require 'rubygems'
require 'mechanize'
require 'rubyful_soup'
require 'optiflag'
require 'yaml'
require 'unicode'
require 'open-uri'

$KCODE = 'UTF-8'


module Newslib

class SoupParser < WWW::Mechanize::Page
  attr_reader :soup
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @soup = BeautifulSoup.new(body) 
    super(uri, response, body, code)
  end
end

class Page
  attr_reader :name
  attr_reader :news
  @@agent = WWW::Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari'; agent.pluggable_parser.html = SoupParser }
  News = Struct.new(:date, :stories)
  
  def initialize(url)
    @url = url
    @page = @@agent.get(@url)
    @news = get_news_with_date
    @name = get_name
    @image = image_uri
  end
  
  def to_yaml
    scrape = {
      :name => @name,
      :stories => @news.map do |n| 
        if n && n.stories
          n.stories.map { |s| story = s.to_a; { :date => n.date, :story => story[0][0], :url => story[0][1] } }
        else
          nil
        end
      end.flatten
    }
    if @image
      scrape[:image] = @image
    end
    scrape.to_yaml
  end
  
  def sync_image(path)
    out_fn_prefix = path + @url.split('http://')[1].split('.')[0].gsub('news', '')
    return false unless @image
    File.open(out_fn_prefix + ".#{@image.split('.').last}", 'wb') do |f| 
      f.puts open(@url, 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)').read 
    end
  end

protected

  def subdomain
    @url.split('http://')[1].split('.')[0].gsub('news', '')
  end
  
  def image_uri
    html = open(@url, 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)').read
    return nil unless html.match(/\/img\/logo/i)
    return "http://#{subdomain}-news.newslib.com/img/logo/#{html.split('/img/logo/')[1].split('"')[0]}"
  end

  def get_name
    @page.soup.find('title').string.split(' News')[0].to_s
  end 

  def get_news_with_date
    dates = @page.soup.find_all('div', :attrs => {'class' => 'date'}).map { |x| x.string.gsub(":", '')}
    dates.map do |date|
      begin
        n = News.new 
        n.date = date.to_s
        n.stories = stories_for_date(@page.body, date)
        n
      rescue
      end
    end
  end
  
  def stories_for_date(html, date)
    BeautifulSoup.new(html.split(date)[1].split('class=date')[0]).find('ul').find_all('a').map { |x| {x.string.to_s, get_orig_story(x.attrs['href']).to_s} }
  end
  
  def get_orig_story(story_url)
    @@agent.get(story_url).frames[1].src
  end
end

class Spider
  ROOT_PAGE = "http://www.newslib.com/viewall.php/"  
  @@agent = WWW::Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari'; agent.pluggable_parser.html = SoupParser }
  
  class << self
    def whole_site
      root_pages.each do |page| 
        page = @@agent.get(page)
        page.links.each { |l| yield Page.new("http://#{l.to_s.gsub(' ', '-')+'-news'}.newslib.com") if ok_name?(l.to_s) }
      end
    end
    
    def auto_spider(outfile, max_threads=9)
      count = 0
      threads = []
      root_pages.each do |cur_page| 
        page = @@agent.get(cur_page)
        page.links.each do |link|
          next unless ok_name?(link.to_s)
          begin
            next if File.stat('./' +link.to_s+'.yml')
          rescue
          end
          threads << Thread.new do
            begin
              File.open('./' +link.to_s+'.yml', 'wb') do |f|
                p = Page.new("http://#{link.to_s.gsub(' ', '-')+'-news'}.newslib.com")
                p.sync_image('./img/')
                f.puts p.to_yaml
              end
            rescue Timeout::Error
              puts "timeout retrying"
              retry
            rescue URI::InvalidURIError
              puts "bad uri skipping"
              File.delete('./' +link.to_s+'.yml')
            rescue
              puts "other problem"
            end
          end
          if threads.size > max_threads
            start_time = Time.now
            threads.each { |t| t.join }
            puts "finished #{threads.size} threads in #{Time.now - start_time} seconds"
            threads = []
          end
        end
      end  
    end
    
    def find_names 
      root_pages.each do |page| 
        page = @@agent.get(page)
        puts page.links
        page.links.each { |l| yield l.to_s if l.to_s.split(' ').size > 1 }
      end
    end
    
  protected
    def ok_name?(name)
      name.split(' ').size > 1 && !name.match(/search/i)
    end
  
    def root_pages
      ('a'..'z').map { |l| ROOT_PAGE + l }
    end
  end
end

end


module CmdLine extend OptiFlagSet
  optional_switch_flag "spider" do
    description "spider the whole site"
  end
  
  optional_switch_flag "names" do
    description "list of all names"
  end
  
  optional_flag "o" do
    description "output to a file"
  end
  optional_flag "url" do 
    description "dump a singe page" 
  end
  optional_flag "pics" do
    description "download pictures to the specified path"
  end
  and_process!
end

#example_news_page = "http://derek-conway-news.Newslib.com/"

if ARGV.flags.o && ARGV.flags.url
  File.open(ARGV.flags.o, 'wb') { |f| f.puts Newslib::Page.new(ARGV.flags.url).to_yaml }
  exit 0
elsif ARGV.flags.o && ARGV.flags.spider
  File.open(ARGV.flags.o, 'wb') do |f|
      Newslib::Spider.auto_spider(ARGV.flags.o)
  end
  exit 0
elsif ARGV.flags.o && ARGV.flags.names
  File.open(ARGV.flags.o, 'wb') do |f|
    Newslib::Spider.find_names { |p| puts "."; f.puts p.to_yaml }
  end
end

if ARGV.flags.url
  puts Newslib::Page.new(ARGV.flags.url).to_yaml
end


#irb(main):001:0> file = File.open('spiders/out.txt', 'r'); out = File.open('spiders/matched.txt', 'wb'); file.each { |l| (puts l; out.puts l) if Person.first :full_name => l.split('--- ')[1].split("\n")[0] }



# if ARGV.flags.o && ARGV.flags.url
#   File.open(ARGV.flags.o, 'wb') { |f| f.puts Newslib::Page.new(ARGV.flags.url).to_yaml }
#   exit 0
# elsif ARGV.flags.o && ARGV.flags.spider
#   File.open(ARGV.flags.o, 'wb') do |f|
#       Newslib::Spider.whole_site do |p|
#         p.sync_image(ARGV.flags.pics) if ARGV.flags.pics
#         f.puts p.to_yaml 
#       end
#   end
#   exit 0
# elsif ARGV.flags.o && ARGV.flags.names
#   File.open(ARGV.flags.o, 'wb') do |f|
#     Newslib::Spider.find_names { |p| puts "."; f.puts p.to_yaml }
#   end
# end
# 
# if ARGV.flags.url
#   puts Newslib::Page.new(ARGV.flags.url).to_yaml
# end



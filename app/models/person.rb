class Person
  include DataMapper::Resource
  
  property :id,         Serial
  property :first_name, String, :nullable => false
  property :last_name,  String, :nullable => false
  property :full_name,  String
  property :permlink,   String
  property :nickname,   String
  property :title,      String
  property :gender,     String
  property :industry,   String
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :assets
  has n, :news_matches
  has n, :news_items, :through => :news_matches
  
  before :save do
    self.full_name = "#{first_name} #{last_name}"
    self.permlink = Permalinks::escape(self.full_name.dup)
  end
  
  validates_length :first_name, :in => 2..20
  validates_length :last_name,  :in => 2..20
  
  def self.import_imdb_file(full_fn, gender)
    File.open(full_fn, 'r').each do |line|
      next unless line =~ /, /
      next if line.split('	')[0].size < 4
      last_name, first_name = line.split('	')[0].split(', ')
      Person.create :first_name => first_name, :last_name => last_name, :gender => gender, :industry => 'film'
    end
    puts "done"
  end
  
  def self.tags_by_most_complete
    res = Set.new
    NewsItem.all(:order => [:images, :updated_at.desc], :limit => 100).each { |i| i.people.each { |p| res << p } }
    #NewsMatch.all(:order => [:created_at], :limit => 150).each { |x| x.person.each { |p| res << p } }
    #NewsItem.all(:order => [:updated_at.desc], :limit => 100).each { |i| i.people.each { |p| res << p }}
    res.to_a
  end
  
  def tag_score
    rss_content = 0
    images = 0
    no_content = 0
    news_items.each do |x| 
      if x.rss_content.nil?
        no_content += 1
      else
        rss_content += 1
      end
      # if x.images
      #        images += x.images.size
      #       end
    end
    
    (rss_content * 1.2) + no_content + (images * 1.3)
  end
  
  def to_param
    self.permlink
  end
end


module Permalinks
  begin
    require 'iconv'
  rescue Object
    puts "no iconv, you might want to look into it."
  end
  require 'digest/sha1'
  
  class << self
    attr_accessor :translation_to
    attr_accessor :translation_from

    # This method does the actual permalink escaping.
    def escape(string)
      result = ((translation_to && translation_from) ? Iconv.iconv(translation_to, translation_from, string) : string).to_s
      result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
      result.gsub!(/[^\w_ \-]+/i,   '') # Remove unwanted chars.
      result.gsub!(/[ \-]+/i,      '-') # No more than one of the separator in a row.
      result.gsub!(/^\-|\-$/i,      '') # Remove leading/trailing separator.
      result.downcase!
      result.size.zero? ? random_permalink(string) : result
    rescue
      random_permalink(string)
    end
    
    def random_permalink(seed = nil)
      Digest::SHA1.hexdigest("#{seed}#{Time.now.to_s.split(//).sort_by {rand}}")
    end
  end
end
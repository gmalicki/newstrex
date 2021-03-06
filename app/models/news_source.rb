class NewsSource
  include DataMapper::Resource
  
  attr_reader :feed
  
  property :id,   Serial
  property :url,  Text,  :nullable => false, :unique => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :news_items
  
  before  :save,   :refresh
  
  def refresh
    begin
      feed_url = Rfeedfinder.feed(url)
      if feed_url && @feed = FeedNormalizer::FeedNormalizer.parse(open(feed_url))
        puts "got feed: #{feed_url}".inspect
        @feed.entries.each do |e|
          next if NewsItem.first(:url => e.url)
          news_items << NewsItem.new(:title => e.title, :url => e.url, :rss_content => e.content, :news_source_id => self.id)
        end
        return true
      end
    rescue
    end
    false
  end
end
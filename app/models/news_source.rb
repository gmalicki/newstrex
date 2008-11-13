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
    feed_url = Rfeedfinder.feed(url)
    if feed_url && @feed = FeedNormalizer::FeedNormalizer.parse(open(feed_url))
      @feed.entries.each do |e|
        news_items << NewsItem.new(:title => e.title, :url => e.url, :rss_content => e.content)
      end
      return true
    end
    false
  end
end
class NewsMatch
  include DataMapper::Resource
  
  property :id,           Serial
  property :news_item_id, Integer, :nullable => false
  property :person_id,    Integer, :nullable => false
  
  belongs_to :person
  belongs_to :news_item
  
  def self.submit_news(news_item)
    count = 0
    return false if NewsItem.first(:url => news_item.url)
    news_item.names.each do |name|
      puts "searching: #{name}"  
      if p = Person.first(:full_name => name)
        NewsMatch.create :person_id => p.id, :news_item_id => news_item.id
        news_item.send :extract_images
        create_permlink(news_item)
        puts "matched: #{name} to #{news_item.url} - images: #{news_item.assets.size > 0}"
        count += 1
      end
    end
    count
  end
  
  def self.create_permlink(news_item)
    Permlink.create(:news_item_id => news_item.id, :permlink => news_item.title)
  end
end

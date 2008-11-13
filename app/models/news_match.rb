class NewsMatch
  include DataMapper::Resource
  
  property :id,           Serial
  property :news_item_id, Integer, :nullable => false
  property :person_id,    Integer, :nullable => false
  
  belongs_to :person
  belongs_to :news_item
  
  def self.submit_news(news_item)
    count = 0
    news_item.names.each do |name|  
      if p = Person.first(:full_name => name)
        NewsMatch.create :person_id => p.id, :news_item_id => news_item.id
        count += 1
      end
    end
    count
  end
end

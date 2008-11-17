class Permlink
  include DataMapper::Resource
  
  property :id, Serial
  property :news_item_id, Integer
  property :permlink, String, :nullable => false, :unique => true
  
  belongs_to :news_item
  
  before :save do
    if item = NewsItem.get(news_item_id)
      item.people.each { |p| self.permlink.gsub!(/#{p.permlink}/i, '') }
      if self.permlink.slice(0,1) == "-"
        self.permlink.slice!(0,1)
      end
      self.permlink.slice!(0,49)
    end
  end
  
  def to_s
    self.permlink
  end
end

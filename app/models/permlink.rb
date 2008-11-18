class Permlink
  include DataMapper::Resource
  
  property :id, Serial
  property :news_item_id, Integer
  property :permlink, String, :nullable => false, :unique => true
  
  belongs_to :news_item
  
  before :valid? do
    if item = NewsItem.get(news_item_id)
      self.permlink = escape_spaces(self.permlink)
      item.people.each { |p| self.permlink.gsub!(/#{p.permlink}/i, '') }
      if self.permlink.slice(0,1) == "-"
        self.permlink.slice!(0,1)
      end
      self.permlink.slice!(0,46)
      if Permlink.first(:permlink => self.permlink)
        self.permlink = self.permlink.slice(0,44)+"-#{rand(31337)}"
        self.permlink.slice!(0,46)
      end
    end
  end
  
  def to_s
    self.permlink
  end
protected
  
  def escape_spaces(title)
    Permalinks::escape(title).slice(0, 46)
  end
end

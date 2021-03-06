class Permlink
  include DataMapper::Resource
  
  property :id, Serial
  property :news_item_id, Integer, :nullable => false
  property :permlink, String, :nullable => false, :unique => true, :length => (1..50)
  
  belongs_to :news_item
  
  before :valid?, :clean_permlink
  
  def to_s
    self.permlink
  end
  
  def clean_permlink
    if item = NewsItem.get(news_item_id)
      self.permlink = escape_spaces(self.permlink)
      item.people.each { |p| self.permlink.gsub!(/#{p.permlink}/i, '') }
      if self.permlink.slice(0,1) == "-"
        self.permlink.slice!(0,1)
      end
      self.permlink.slice!(49, 60)
      if Permlink.first(:permlink => self.permlink)
        self.permlink = self.permlink.slice(0,44)+"-#{rand(31337)}"
        self.permlink.slice!(49,60)
      end
      if self.permlink.size < 5
        self.permlink = "#{rand(31337999)}"
      end
    end
  end
  
protected
  def escape_spaces(title)
    Permalinks::escape(title).slice(0, 46)
  end
end

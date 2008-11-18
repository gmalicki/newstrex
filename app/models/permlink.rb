class Permlink
  include DataMapper::Resource
  
  property :id, Serial
  property :news_item_id, Integer
  property :permlink, String, :nullable => false, :unique => true
  
  belongs_to :news_item
  
  #before :valid?, :clean_permlink
  
  def to_s
    self.permlink
  end
  
  def clean_permlink
    if item = NewsItem.get(news_item_id)
      self.permlink = escape_spaces(self.permlink)
      raise "permlink is blank" if self.permlink.nil? || self.permlink.size == 0
      item.people.each { |p| self.permlink.gsub!(/#{p.permlink}/i, '') }
      if self.permlink.slice(0,1) == "-"
        self.permlink.slice!(0,1)
      end
      raise "permlink is blank1" if self.permlink.nil? || self.permlink.size == 0
      self.permlink.slice!(45, 60)
      raise "permlink is blank2" if self.permlink.nil? || self.permlink.size == 0
      if Permlink.first(:permlink => self.permlink)
        self.permlink = self.permlink.slice(0,44)+"-#{rand(31337)}"
        self.permlink.slice!(45,60)
      end
    else 
      raise "invalid news_item_id"
    end
  end
  
protected
  def escape_spaces(title)
    Permalinks::escape(title).slice(0, 46)
  end
end

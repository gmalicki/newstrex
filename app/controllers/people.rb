class People < Application  
  @@cloud = nil
  
  def index
    render "foo"
  end
  
  def show(permlink)
    @person = Person.first(:permlink => permlink.split(/\-news/i)[0])
    @items  = @person.news_items.map { |i| i if i.title.size > 5 } # TODO remove this map, validation makes it not needed
    raise NotFound unless @person
    @rss_items = @items.map { |i| i unless i.rss_content.nil? }.compact
    @rss_items.each do |i| 
          if i.permlinks.empty?
            p = Permlink.new(:news_item_id => i.id, :permlink => i.title)
            x =  p.save
            raise p.errors.inspect unless x
          end
        end
    @items  = @person.news_items.map { |i| i if i.title.size > 5 && i.permlinks.size > 0 }
    @rss_items = @items.map { |i| i unless i.rss_content.nil?}.compact
    @headlines = @items.map { |i| i if i.rss_content.nil? }.compact
    if @@cloud.nil?
      puts "TAAGGGGSSS BY MOST COMPOETELELELKJ!!!"
      @@cloud = Person.tags_by_most_complete
    end
    @cloud = @@cloud
    render
  end
end

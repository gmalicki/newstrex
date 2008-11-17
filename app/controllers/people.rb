class People < Application  
  @@cloud = nil
  
  def index
    render "foo"
  end
  
  def show(permlink)
    @person = Person.first(:permlink => permlink.split(/\-news/i)[0])
    @items  = @person.news_items
    raise NotFound unless @person
    @rss_items = @items.all :rss_content.not => nil 
    @rss_items.each { |i| raise "hrmm" if i.permlinks.empty?}
    @headlines = @items.all :rss_content => nil
    if @@cloud.nil?
      puts "TAAGGGGSSS BY MOST COMPOETELELELKJ!!!"
      @@cloud = Person.tags_by_most_complete
    end
    @cloud = @@cloud
    render
  end
end

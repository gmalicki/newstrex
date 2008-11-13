class People < Application  
  # ...and remember, everything returned from an action
  # goes to the client...
  
  @@cloud = nil
  
  def index
    render "foo"
  end
  
  def show(permlink)
    @person = Person.first :permlink => permlink
    @items  = @person.news_items
    raise NotFound unless @person
    @rss_items = @items.all :rss_content.not => nil 
    @headlines = @items.all :rss_content => nil
    if @@cloud.nil?
      puts "TAAGGGGSSS BY MOST COMPOETELELELKJ!!!"
      @@cloud = Person.tags_by_most_complete
    end
    @cloud = @@cloud
    render
  end
end

class People < Application  
  @@cloud = nil
  cache :index, :show
  #eager_cache :index, :show
  
  def index
    render "foo"
  end
  
  def show(permlink)
    @person = Person.first(:permlink => permlink.split(/\-news/i)[0])
    unless @person
      return redirect('/')
    end
    @items = @person.news_items
    @rss_items = @items.map { |i| i unless i.rss_content.nil? }.compact
    @rss_items.each do |i| 
          if i.permlinks.empty?
            p = Permlink.new(:news_item_id => i.id, :permlink => i.title)
            x =  p.save
            raise p.errors.inspect unless x
          end
        end
    @rss_items = @items.map { |i| i unless i.rss_content.nil? && i.permlinks.size > 0 }.compact
    @rss_items.sort! { |x, y| x.assets.size <=> x.assets.size }
    @rss_items.sort! { |x, y| x.content.split(/#{@person.full_name}/i).size <=> y.content.split(/#{@person.full_name}/i).size }
    @headlines = @items.map { |i| i if i.rss_content.nil? }.compact
    if @@cloud.nil?
      puts "TAAGGGGSSS BY MOST COMPOETELELELKJ!!!"
      @@cloud = Person.tags_by_most_complete
    end
    @cloud = @@cloud
    render
  end
end

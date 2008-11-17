class Stories < Application
  @@cloud = nil

  def show(storylink, permlink)
    @item = NewsItem.from_permlink(storylink)
    @person = Person.first(:permlink => permlink)
    raise NotFound unless @item
    if @@cloud.nil?
      puts "TAAGGGGSSS BY MOST COMPOETELELELKJ!!!"
      @@cloud = Person.tags_by_most_complete
    end
    @cloud = @@cloud
    display @item
  end

end # Stories

require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe NewsMatch do
  
  before(:each) do
    Person.all.each { |x| x.destroy }
    NewsSource.all.each { |x| x.destroy }
    NewsItem.all.each { |x| x.destroy }
    NewsMatch.all.each { |x| x.destroy }
  end

  it "should be able to associate a person with new_items" do
    p = Person.create(:first_name => 'gabe', :last_name => 'malicki')
    p.news_items.nil?.should == false
    p.news_items.size.should == 0
    s = NewsSource.create(:url => 'http://www.reddit.com')
    s.news_items.size.should > 0
    NewsMatch.create :person_id => p.id, :news_item_id => s.news_items.first.id
    NewsMatch.count.should == 1
    p.reload
    p.news_items.size.should > 0 
    i = p.news_items.first
    i.people.include?(p).should == true
  end
  
  # it "should save a NewsMatch instance when sent .submit_news and passed a news_item_id and a qeury query" do
  #   lambda { NewsItem.submit_news()}.should be_different_by(0) { @s.refresh.should == false }
  # end
end
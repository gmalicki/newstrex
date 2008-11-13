require File.join( File.dirname(__FILE__), '..', "spec_helper" )

# this spec requries an active internet connection.
describe "A NewsSource instance intitalized for reddit.com" do
  before(:each) do
    NewsSource.all.each { |i| i.destroy }
    @s = NewsSource.new :url => 'http://www.reddit.com'
    NewsItem.all.each { |i| i.destroy }
  end
  
  it "should create a NewsItem instance for each feed entry when saved" do
    lambda { NewsItem.count }.should be_different_by(25) { @s.save }  # reddit holds steady at 25 posts.
  end
end

describe "A NewsSource instance which has been initalized for reddit.com and refreshed" do
  before(:each) do
    @s = NewsSource.new :url => 'http://www.reddit.com'
    @s.refresh
  end
  
  it "should return a feed with several entries when sent #feed" do
    @s.feed.nil?.should == false
    @s.feed.class.should == FeedNormalizer::Feed
    @s.feed.entries.size.should == 25 # we like to help test reddit too :)
  end
end

describe "A NewsSource instance which has been initialized with a bogus url" do
  before(:each) do
    @s = NewsSource.new :url => "blah"
  end
  
  it "should raise an exception when sent #refresh" do
    lambda { @s.refresh }.should raise_error(ArgumentError)
  end
end

describe "A NewsSource instance which has been initialized with a url that does not contain a feed" do
  before(:each) do
    @s = NewsSource.new :url => "http://istheinternetfuckingawesome.com/"
  end
  
  it "should return false and not create any NewsItem instances when sent #refresh" do
    lambda { NewsItem.count}.should be_different_by(0) { @s.refresh.should == false }
  end
end

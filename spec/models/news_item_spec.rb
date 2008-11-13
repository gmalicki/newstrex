require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe "A NewsItem instance that has been initialized with all required attributes" do
  before(:each) do
    @i = NewsItem.new :url => "http://www.reddit.com", :title => 'gabe rules', :rss_content => 'foo <a href="http://www.reddit.com">bar</a>'
  end
  
  # it "should be capable of seralizing any ruby object to the names property" do
  #   @i.names = %w(foo bar)
  #   @i.save.should == true
  #   @i.reload
  #   @i.names.should == %w(foo bar)
  # end
  
  it "should return the rss_content with all anchor tags removed when sent #content_plain_text" do
    pt= @i.send :content_plain_text
    pt.match('</a>').nil?.should == true
    pt.match('<a href>').nil?.should == true
    pt.match('bar').nil?.should == false
    pt.should == "foo bar"
  end
end

describe "A NewsItem instance that has been initialized with with information about Albert Einstein" do
  before(:each) do
    NewsItem.all.each { |i| i.destroy }
    @i = NewsItem.new :url => "http://en.wikipedia.org/wiki/Albert_Einstein", 
      :title => 'gabe rules', 
      :rss_content => "Albert Einstein was a really smart dude.  Gabe Malicki's computer is pretty smart too."
  end
  
  it "should populate the names attribute with all first and last names contained within rss_content when sent #extract_names" do
    @i.send :extract_names
    @i.names.nil?.should == false
    @i.names.include?('Albert Einstein').should == true
    @i.names.include?('Gabe Malicki').should == true
  end
end


# describe "A NewsItem instance that has been initialized with with html that includes an image" do
#   before(:each) do
#     NewsItem.all.each { |i| i.destroy }
#     @i = NewsItem.new :url => "http://en.wikipedia.org/wiki/Albert_Einstein", 
#       :title => 'gabe rules', 
#       :rss_content => "<img src=\"http://www.aceshowbiz.com/images/news/00019732.jpg\" hspace=\"5\" align=\"right\" width=\"200\" height=\"176\">\nWhile NBC's Jay Leno gets John McCain's first appearance on November 11, Greta Van Susteren gets Sarah Palin's interview for FOX directly from Alaska on November 10.\n<p><a href=\"http://feeds.feedburner.com/~a/Aceshowbizcom-EntertainmentNews?a=axY6Im\"><img src=\"http://feeds.feedburner.com/~a/Aceshowbizcom-EntertainmentNews?i=axY6Im\" border=\"0\"></img></a></p>"
#   end
#   
#   it "should save the image to the filesystem when saved" do
#     @i.save.should == true
#     @i.images.nil?.should == false
#   end
# end
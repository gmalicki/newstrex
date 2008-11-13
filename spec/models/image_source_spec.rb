require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe ImageSource do
  before(:each) do
    @save_path = '/tmp/'
    @html = "<img src=\"http://www.aceshowbiz.com/images/news/00019732.jpg\" hspace=\"5\" align=\"right\" width=\"200\" height=\"176\">\nWhile NBC's Jay Leno gets John McCain's first appearance on November 11, Greta Van Susteren gets Sarah Palin's interview for FOX directly from Alaska on November 10.\n<p><a href=\"http://feeds.feedburner.com/~a/Aceshowbizcom-EntertainmentNews?a=axY6Im\"><img src=\"http://feeds.feedburner.com/~a/Aceshowbizcom-EntertainmentNews?i=axY6Im\" border=\"0\"></img></a></p>"
    @is = ImageSource.new(@html, @save_path)
  end
  
  it "should save the images to disk" do
    @is.images.size.should == 2
    @is.images.each { |i| File.stat(@save_path + i).nil?.should == false }
  end
end
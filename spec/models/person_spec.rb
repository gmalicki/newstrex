require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Person do
  # before(:each) do
  #   @p = Person.new
  # end
  
  

  it "should not persist unless a first and last name are present" do
    Person.create.id.nil?.should == true
    Person.create(:first_name => 'foo').id.nil?.should == true
    Person.create(:first_name => 'foo', :last_name => 'bar').id.nil?.should == false
  end
  
  it "should have a news_items assoication" do
    p = Person.new
    p.news_items.nil?.should == false
  end
  
  it "should have a news_matches association" do
    p = Person.new
    p.news_matches.nil?.should == false
  end
  
  it "should import from a file" do 
    #Person.import_imdb_file File.join( File.dirname(__FILE__), '..', '..', '..', "workspace", 'actresses.list' ) , 'f'
  end
  
  it "should have an assets assocation" do
    p = Person.new
    p.assets.should == []
  end
  
  # it "should generate a known_as attribute before saving a new record if one does not already exist" do
  #   @p.first_name = "Gabe"
  #   @p.last_name = "Malicki"
  #   @p.save.should == true
  #   @p.known_as.nil?.should == false
  #   @p.known_as.class.should == String
  #   @p.known_as.size.should > 2
  # end
end
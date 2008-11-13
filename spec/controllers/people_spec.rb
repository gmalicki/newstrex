require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe People, "index action" do
  before(:each) do
    dispatch_to(People, :index)
  end
end
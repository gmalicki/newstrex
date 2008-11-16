require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe "An Asset with data in it's outgoing queue" do
  
  IMG_MESSAGE = 
  "image:
    id: 923
    bucket: newstrex-images
    original: 
      file_name: foo.jpg
      height: 20
      width: 20
      mime-type: image/jpeg
      size: 2009
    small: 
      file_name: foo-small.jpg
      height: 20
      width: 20
      mime-type: image/jpeg
      size: 2009"

  before do
    @s3_config = YAML.load_file(Merb.root + '/config/amazon_s3.yml')[Merb.env].symbolize_keys!
    @sqs_connection = RightAws::Sqs.new(@s3_config['access_key_id'], @s3_config['secret_access_key'])
    @queue = RightAws::Sqs::Queue.create(@sqs_connection, @s3_config['out_queue'], true)
  end
  
  
  before(:each) do

  end
  
  it "should update the original record and save any relivant children when sent .process_new_content" do
    msg = {'image' => {'id' => 2, 'bucket' => 'newstrex-images', 'original' => {
      'file_name' => 'foo.jpg', 'height' => 20, 'width' => 20, 'mime-type' => 'image/jpeg', 'size' => 2009
    } }, 'small' => {
      'file_name' => 'foo-small.jpg', 'height' => 20, 'width' => 20, 'mime-type' => 'image/jpeg', 'size' => 2009
    }}
    @queue.send_message(msg.to_yaml)
    @queue.size.should > 0
    create_call = {
                     :file_name => 'foo-small.jpg', 
                     :s3_bucket => @s3_config['bucket'], 
                     :parent_id => 923, 
                     :mime_type => 'image/jpeg',
                     :height => 20,
                     :width => 20, 
                     :size => 2009 }
    Asset.should_receive(:create).with(create_call).and_return(mock('Asset'))
    Asset.process_new_content
    @queue.size.should == 0
  end
end
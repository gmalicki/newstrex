class Asset
  include DataMapper::Resource
  
  property :id,               Serial
  property :file_name,        String
  property :s3_bucket,        String
  property :md5_checksum,     String
  property :content_type,     String
  property :size,             Integer
  property :parent_id,        Integer
  property :person_id,        Integer
  property :news_item_id,     Integer
  property :thumbnail,        String
  property :width,            Integer
  property :height,           Integer
  property :created_at,       DateTime
  property :title,            String
  property :thumbnails_count, Integer, :default => 0
  
  belongs_to  :person
  belongs_to  :news_item
  
  after :save, :sync_to_primary_storage
  @@s3_config = YAML.load_file(Merb.root + '/config/amazon_s3.yml')[Merb.env] || {
    'access_key_id' => '1GZFKYFWGM2WEAZFZ202',
    'secret_access_key' => 'gcD9Y9FYrJ8XvJptCNVnjG+jdgT+ozLnaV+WHfoC'
  }
  @@sqs_connection = RightAws::Sqs.new(@@s3_config['access_key_id'], @@s3_config['secret_access_key'])
  TEMP_STORAGE = Merb.root + '/tmp/'
  attr_accessor :url
  
  def self.process_new_media
    out_queue = @@sqs_connection.queue(@@s3_config['out_queue'])
    loop do
      return nil if out_queue.size == 0
      msg = YAML.load(out_queue.pop.to_s)
      if msg.nil?
        next
      end
      if msg[:story]
        process_news(msg)
        next
      end
      img = msg['image']
      next unless img
      if Asset.first(:md5_checksum => img['md5']) # skip it if we already have it.
        next
      end
      raise "rouge record found in message queue" if img.class != Hash
      # take an image record and update the db accordingly.
      if parent = Asset.first(:id => img['id'])
        parent.file_name = img['original']['file_name']
        parent.s3_bucket = img['bucket']
        parent.md5_checksum = img['md5']
        parent.save
        puts "parent: #{parent.file_name}"
      end
      Asset.all(:parent_id => img['id']).each { |x| x.destroy }
      %w(large medium small).each do |size|
        if parent && i = img[size]
          Asset.create(:file_name => i['file_name'], 
                       :s3_bucket => img['bucket'], 
                       :parent_id => img['id'],
                       :height => i['height'],
                       :width => i['width'], 
                       :size => i['size'])
          puts "child: #{i['file_name']}"
        end
      end
    end      
  end
  
  def self.process_news(item)
    next unless item[:story] && item[:date] && item[:headline] && item[:url] && item[:topic]
    if person = Person.first(:full_name => item[:topic].split(' ').map { |x| x.capitalize }.join(" "))
      s = NewsSource.create :url => item[:source_desc]
      if !s.valid?
        s = NewsSource.first(:url => item[:source_desc])
      end
      if item[:date] > Time.now
        item[:date] = Time.now
      end
      i = NewsItem.new(:title => item[:headline], 
        :rss_content => item[:story], 
        :url => item[:url], 
        :published_at => item[:date], :news_source => s)
      if i.save
        NewsMatch.create :person_id => person.id, :news_item_id => i.id
      else 
        puts i.errors.inspect
      end
    end
  end
  
  def self.save_rss_media(news_item)
    if html = news_item.rss_content
      image_urls(html).each { |uri| Asset.create(:news_item_id => news_item.id, :url => uri) }
    end
  end
  
  def self.save_person_media(person, url_to_image)
    Asset.create :person_id => person.id, :url => url_to_image
  end
  
  def small_thumb
    Asset.first :parent_id => self.id, :order => [:height.asc]
  end
  
  def medium_thumb
    Asset.first :parent_id => self.id, :order => [:height.desc]
  end
  
protected  
  # parse the html blob and return the url for each image.
  def self.image_urls(html)
    begin
      soup = BeautifulSoup.new(html)
      soup.find_all('img').map { |img| img['src'] }
    rescue
      []
    end
  end

  def sync_to_primary_storage
    if url
      in_queue = @@sqs_connection.queue(@@s3_config['in_queue'])
      in_queue.send_message({:image => { :id => self.id, :url => url }}.to_yaml)
      true
    end
  end
end

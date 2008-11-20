require 'rubygems'
require 'mechanize'
require 'rubyful_soup'
require 'right_aws'
require 'optiflag'
require 'yaml'
require 'unicode'
require 'open-uri'
require 'cgi'

$KCODE = 'UTF-8'


module Topix

class Spider
  SEARCH = "http://www.topix.com/search/article?q="
  @@agent = WWW::Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  
  def self.content(query)
    threads = []
    page = @@agent.get(SEARCH+query.gsub(' ','+'))
    stories = extract(page)
    threads << Thread.new do
      (2..10).each do |i|
        page = @@agent.get(SEARCH.split('article?')[0] +"article/p#{i}?q=" + query.gsub(' ','+'))
        begin
          stories += extract(page)
        rescue
        end
      end
    end
    threads.each { |t| t.join }
    stories
  end
  
protected  

  def self.next_page(page)
    false
  end
  
  def self.extract(page)
    headlines = page.search("//p[@class='headline']").map { |h| CGI.escapeHTML(h.inner_text.split('</img')[0].gsub("\n", '').gsub('"', '')) }
    timestamps = page.search("//p[@class='timestamp']").map { |s| Time.parse(CGI.escapeHTML(s.inner_text.split(' |')[0].gsub("\n", ''))) }
    source_names = page.search("//p[@class='timestamp']").map { |n| CGI.escapeHTML(n.inner_text.split('| ')[1].split('<')[0].gsub("\n", '')) }
    stories = page.search("//p[@class='lede']").map { |x| x.inner_text.split('</input')[0].gsub("\n", '').split('Comment?')[0].gsub(' ...','') }
    url = page.search("//a[@t='artclick']").map { |x| x.to_s.split('<a href="')[1].split('"')[0] }
    res = []
    headlines.each_with_index { |h, idx| res << {:url => url[idx], :headline => h, :date => timestamps[idx], :story => stories[idx], :source_desc => source_names[idx] } }
    res
  end
end

end


module CmdLine extend OptiFlagSet
  optional_flag "query" do 
    description "preform a search query" 
  end
  
  optional_switch_flag "sync" do
    description "write results to the SQS queue"
  end
  and_process!
end


IN_QUEUE = 'newstrex-pending'
OUT_QUEUE = 'newstrex-finished'
ACCESS_KEY_ID = '1GZFKYFWGM2WEAZFZ202'
SECRET_ACCESS_KEY = 'gcD9Y9FYrJ8XvJptCNVnjG+jdgT+ozLnaV+WHfoC'

def sync_stories(stories)
  sqs_connection = RightAws::Sqs.new(ACCESS_KEY_ID, SECRET_ACCESS_KEY)
  out    = sqs_connection.queue(OUT_QUEUE)
  stories.each { |story| out.send_message(story.to_yaml)}
end

if query = ARGV.flags.query
  stories = Topix::Spider.content(query).map do |story| 
    story[:topic] = ARGV.flags.query
    story
  end
  sync_stories(stories) if ARGV.flags.sync 
  stories.each { |s| puts s.to_yaml }
end




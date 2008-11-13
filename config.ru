ENV['GEM_PATH'] = '/home/ah1337/newstrex.dreamhosters.com/shared/gems/'

require 'rubygems' 
require 'merb-core' 
 
Merb::Config.setup(:merb_root   => ".", 
                   :environment => ENV['RACK_ENV']) 
Merb.environment = Merb::Config[:environment] 
Merb.root = Merb::Config[:merb_root] 
Merb::BootLoader.run 
 
run Merb::Rack::Application.new
ENV['GEM_PATH'] = '/home/ah1337/newstrex.dreamhosters.com/shared/gems/'

require 'rubygems' 

["/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/abstract-1.0.0/bin", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/abstract-1.0.0/lib", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/erubis-2.6.2/bin", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/erubis-2.6.2/lib", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/json_pure-1.1.3/bin", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/json_pure-1.1.3/lib", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/rspec-1.1.11/bin", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems//gems/rspec-1.1.11/lib", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/mime-types-1.15/bin", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/mime-types-1.15/lib", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/merb-core-0.9.13/bin", 
"/home/ah1337/newstrex.dreamhosters.com/shared/gems/gems/merb-core-0.9.13/lib"].each do |path|
  $LOAD_PATH << path
end

require 'merb-core' 
 
Merb::Config.setup(:merb_root   => ".", 
                   :environment => ENV['RACK_ENV']) 
Merb.environment = Merb::Config[:environment] 
Merb.root = Merb::Config[:merb_root] 
Merb::BootLoader.run 
 
run Merb::Rack::Application.new



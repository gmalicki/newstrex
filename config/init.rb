# Go to http://wiki.merbivore.com/pages/init-rb

# needed for dreamhost for some reason.
class Time
  def to_date
    Date.parse(self.to_formatted_s(:db))
  end
end
 
require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = '55a1fb30743120621a740c73491bc101cafdde68'  # required for cookie session store
  # c[:session_id_key] = '_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
  
  # hack! remove this when we upgrade.
  # this is ugly and is only here becuase of this bug: http://wm.lighthouseapp.com/projects/4819/tickets/408-argumenterror-adapter-not-set-default-did-you-forget-to-setup
  # which has been fixed in merb > 9.2
  DataMapper.setup(:default, {
    :adapter => 'mysql',
    :encoding => 'utf8',
    :database => 'newstrex_prod',
    :username => 'gouki',
    :password => 'Ge0rge', 
    :host => 'mysql.gouki.dreamhosters.com',
    :port => 3306
  })
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
end


RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

ALONETONE = YAML.load_file("#{RAILS_ROOT}/config/alonetone.yml")[RAILS_ENV]

class << ALONETONE
  ALONETONE.keys.each do |key|
    class_eval "def #{key}; ALONETONE['#{key}']; end"
  end  
end


Rails::Initializer.run do |config|


  # load gems from vendor
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end

  config.action_controller.session = {
    :session_key => 'alonetone_cookie',
    :secret => ALONETONE.secret
  }


  config.cache_store = :mem_cache_store, "localhost:11211"

  config.active_record.observers = :user_observer, :comment_observer, :asset_observer
  
  # Required hack to inform rails we have files in models/user and models/asset
  # Essentially lets us use concerned_with in development mode
  config.autoload_paths += Dir[
    File.join(Rails.root,'app','models','**')
   ].reject{ |f| !File.directory?(f) }
end
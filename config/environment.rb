RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  config.gem 'ruby-mp3info',  :lib => 'mp3info'
  config.gem 'rubyzip',       :lib => 'zip/zip'
  config.gem 'googlecharts',  :lib => 'gchart'
  config.gem 'haml'
  config.gem 'newrelic_rpm'
  config.gem 'BlueCloth',     :lib => 'bluecloth' 
  config.gem 'hpricot' # for comment processing / markdown fixing
  config.gem 'mislav-will_paginate', :lib => 'will_paginate'
  
  config.gem "rspec", :lib => false, :version => ">= 1.2.0"
  config.gem "rspec-rails", :lib => false, :version => ">= 1.2.0"  
  
  # Rmagick is *not* required (for example, sudara uses imagescience)
  # config.gem 'rmagick',       :lib => 'RMagick'


  # load gems from vendor
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end

  config.action_controller.session = {
    :session_key => 'alonetone_com',
  }
  config.cache_store = :mem_cache_store, "localhost:11211"
  config.action_controller.session_store = :active_record_store

  config.active_record.observers = :user_observer, :comment_observer, :asset_observer
end
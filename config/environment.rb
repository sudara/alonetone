RAILS_GEM_VERSION = '2.1.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  config.gem 'ruby-mp3info',  :lib => 'mp3info'
  config.gem 'rubyzip',       :lib => 'zip/zip'
  config.gem 'googlecharts',  :lib => 'gchart'
  config.gem 'json'
  config.gem 'haml'
  
  # Rmagick is *not* required (for example, sudara uses imagescience)
  # config.gem 'rmagick',       :lib => 'RMagick'


  # load gems from vendor
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end

  config.action_controller.session = {
    :session_key => 'alonetone_com',
  }

  config.action_controller.session_store = :active_record_store

  config.active_record.observers = :user_observer, :comment_observer
end
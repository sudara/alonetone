# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Alonetone::Application.initialize!

# config.cache_store = :mem_cache_store, "localhost:11211"

# config.active_record.observers = :user_observer, :comment_observer, :asset_observer
# 
# # Required hack to inform rails we have files in models/user and models/asset
# # Essentially lets us use concerned_with in development mode
# config.autoload_paths += Dir[
#   File.join(Rails.root,'app','models','**')
#  ].reject{ |f| !File.directory?(f) }
#nd
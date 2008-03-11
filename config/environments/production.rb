# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false



config.after_initialize do
    require 'application' unless Object.const_defined?(:ApplicationController)
    LoggedExceptionsController.class_eval do
      # set the same session key as the app
      session :session_key => 'alonetone_com'

      # include any custom auth modules you need
      include AuthenticatedSystem
      protect_from_forgery  :secret => YAML.load_file(File.join(RAILS_ROOT,'config','alonetone.yml'))['alonetone']['secret']

      before_filter :login_required
      
      # optional, sets the application name for the rss feeds
      self.application_name = "alonetone"
      
      protected
        # only allow admins
        # this obviously depends on how your auth system works
        def authorized?
          logged_in? && current_user.admin?
        end
        
        # assume app's login required doesn't use http basic
        def login_required_with_basic
          respond_to do |accepts|
            # alias_method_chain will alias the app's login_required to login_required_without_basic
            accepts.html { login_required_without_basic }
            
            # access_denied_with_basic_auth is defined in LoggedExceptionsController
            # get_auth_data returns back the user/password pair
            accepts.rss do
              access_denied_with_basic_auth unless self.current_user = User.authenticate(*get_auth_data)
            end
          end
        end
        
        alias_method_chain :login_required, :basic
    end
  end

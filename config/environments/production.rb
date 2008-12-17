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
ey_smtp_settings = {
  :domain             => "nextkillerapp.com", # CHANGEME
  :address            => "smtp",
  :port               => 25,
  :perform_deliveries => true
}

config.action_mailer.smtp_settings   = ey_smtp_settings
config.action_mailer.delivery_method = :smtp
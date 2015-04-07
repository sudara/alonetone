Alonetone::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :test

  # Uncomment to deliver mail in development
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = config_for(:alonetone)['smtp_settings'].symbolize_keys

  # Uncomment to use sidekiq
  # config.active_job.queue_adapter = :sidekiq

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  #config.middleware.use "Insight::App", :secret_key => "alonetoneisaliveandwellletsdothis"
  config.action_mailer.default_url_options = { :host => "localhost:3000" }
    
  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  
  # SSSShhhh!!!! Assets shuddup!
  config.assets.logger = nil
  
  # Sometimes we want to use the real rakismet
  config.rakismet.test = false
end

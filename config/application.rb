require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Alonetone
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.load_defaults 5.2

    config.exceptions_app = self.routes

    config.assets.paths.concat(
      Compass::Frameworks::ALL.map { |f| f.stylesheets_directory }
    )
    config.active_record.sqlite3.represent_boolean_as_integer = true
    config.assets.quiet = true
  end
end

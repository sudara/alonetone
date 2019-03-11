require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/configurable'

# * Configuration values go in configuration/alonetone.yml.
# * Settings in config/environments/* override those specified here.
# * Library initialization should happen in a file in config/initializers.
module Alonetone
  class Application < Rails::Application
    # Load config/alonetone.yml and rescue when it's not there so the setup
    # tasks work.
    begin
      config.alonetone = ::Configurable.new(Rails.env.to_s, config_for(:alonetone))
    rescue RuntimeError
      config.alonetone = ::Configurable.new(Rails.env.to_s, {})
    end

    config.load_defaults 5.2

    config.exceptions_app = routes

    config.assets.paths.concat(Compass::Frameworks::ALL.map(&:stylesheets_directory))
    config.assets.quiet = true

    config.action_mailer.default_url_options = { host: config.alonetone.hostname }

    config.active_storage.service = config.alonetone.storage_service

    def cloudfront_enabled?
      remote_storage? &&
        config.alonetone.amazon_cloud_front_domain_name.present? &&
        config.alonetone.amazon_cloud_front_key_pair_id.present?
    end

    def remote_storage?
      config.active_storage.service.to_s == 's3'
    end

    def show_dummy_image?
      config.alonetone.show_dummy_image == true
    end

    def play_dummy_audio?
      config.alonetone.play_dummy_audio == true
    end
  end
end

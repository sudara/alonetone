# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'authlogic/test_case'
require 'factory_bot_rails'
require "selenium/webdriver"
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu no-sandbox) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome
Percy.config.default_widths = [375, 1280]

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.before(:suite) { Percy::Capybara.initialize_build }
  config.after(:suite) { Percy::Capybara.finalize_build }

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.render_views

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!

  config.include Authlogic::TestCase
  config.include RSpec::Support::Logging
  config.include RSpec::Support::LittleHelpers
  config.include RSpec::Support::LoginHelpers
  config.include ActiveSupport::Testing::TimeHelpers

  config.before(:suite) do
    InvisibleCaptcha.timestamp_enabled = false
  end

  config.include Authlogic::TestCase, type: :request
  config.include Authlogic::TestCase, type: :controller

  config.before(:example, type: :request) do
    activate_authlogic
  end

  config.before(:example, type: :controller) do
    activate_authlogic
  end
end

FactoryBot.reload

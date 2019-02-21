# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'capybara/rspec'
require 'selenium/webdriver'

# The suite needs to be able to connect to localhost for feature specs. Percy
# sends its build response out of the test process so it also needs to connect
# to its API.
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: 'percy.io'
)

# Reloads schema.rb when database has pending migrations.
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Magic incantation to make Capybara run the feature specs. Nobody knows
# why this isn't a default in the gem.
Capybara.register_driver(:headless_chrome) do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w[headless disable-gpu no-sandbox] }
    )
  )
end
Capybara.javascript_driver = :headless_chrome
# Configure the HTTP server to be silent. Note that Capybara would figure out
# to use Puma on its own if we remove this line.
Capybara.server = :puma, { Silent: true }

# Set default resolutions for visual regression testing.
Percy.config.default_widths = [375, 1280]

RSpec.configure do |config|
  # Use Active Record fixture path relative to spec/ directory.
  config.fixture_path = Rails.root.join('spec', 'fixtures').to_s

  # All of the fixtures all of the time.
  config.global_fixtures = :all

  # Use transactional fixtures.
  config.use_transactional_fixtures = true

  # Spec directory determines its type (e.g. models, requests, etc).
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Render views in controller specs by default.
  config.render_views

  config.include ActiveJob::TestHelper
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Authlogic::TestCase, type: :controller
  config.include Authlogic::TestCase, type: :request
  config.include RSpec::Support::AkismetHelpers
  config.include RSpec::Support::FileFixtureHelpers
  config.include RSpec::Support::HTMLMatchers, type: :helper
  config.include RSpec::Support::HTMLMatchers, type: :request
  config.include RSpec::Support::LittleHelpers
  config.include RSpec::Support::Logging
  config.include RSpec::Support::LoginHelpers

  config.before(:suite) do
    Percy::Capybara.initialize_build
    InvisibleCaptcha.timestamp_enabled = false
  end

  config.before(:each) do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  config.before(:example, type: :request) do
    activate_authlogic
  end

  config.before(:example, type: :controller) do
    activate_authlogic
  end

  config.after(:suite) do
    Percy::Capybara.finalize_build
  end
end

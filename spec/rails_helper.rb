# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'capybara/rspec'
require 'selenium/webdriver'
require 'percy'

# The suite needs to be able to connect to localhost for feature specs. Percy
# sends its build response out of the test process so it also needs to connect
# to its API.
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ['percy.io', 'chromedriver.storage.googleapis.com']
)

# Reloads schema.rb when database has pending migrations.
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Include helpers into the fixture context to generate data which is hard
# to write by hand.
ActiveRecord::FixtureSet.context_class.include RSpec::Support::EncryptionHelpers
ActiveRecord::FixtureSet.context_class.include RSpec::Support::WaveformHelpers

# Magic incantation to make Capybara run the feature specs. Nobody knows
# why this isn't a default in the gem.
Capybara.register_driver(:headless_chrome) do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox disable-gpu])
  options.headless! # comment out to view feature tests in active browser

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    options: options
end
Capybara.javascript_driver = :headless_chrome
# Configure the HTTP server to be silent. Note that Capybara would figure out
# to use Puma on its own if we remove this line.
Capybara.server = :puma, { Silent: true }

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
  config.include RSpec::Support::CapybaraHelpers, type: :feature
  config.include RSpec::Support::ConfigurationHelpers
  config.include RSpec::Support::FileFixtureHelpers
  config.include RSpec::Support::HTMLMatchers, type: :helper
  config.include RSpec::Support::HTMLMatchers, type: :request
  config.include RSpec::Support::LittleHelpers
  config.include RSpec::Support::Logging
  config.include RSpec::Support::LoginHelpers
  config.include RSpec::Support::QueryMatchers
  config.include RSpec::Support::StorageServiceHelpers

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
end

# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/playwright'
require 'percy/capybara'

# The suite needs to be able to connect to localhost for feature specs.
# Percy sends its build response out of the test process so it also needs to connect
# to its API.
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ['percy.io',
    'ownandship.io',
    'cdn.alonetone.com', # fonts
    'github.com',
    'github-releases.githubusercontent.com'])

# Reloads schema.rb when database has pending migrations.
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Include helpers into the fixture context to generate data which is hard
# to write by hand.
ActiveRecord::FixtureSet.context_class.include RSpec::Support::EncryptionHelpers
ActiveRecord::FixtureSet.context_class.include RSpec::Support::WaveformHelpers

Capybara.register_driver :alonetone do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: ENV['HEADED'].blank?,
    # GitHub Actions runners run as root; chromium refuses to start without --no-sandbox.
    chromiumSandbox: ENV['CI'].blank?
  )
end
Capybara.default_driver = :alonetone
Capybara.javascript_driver = :alonetone

# Configure the HTTP server to be silent. Note that Capybara would figure out
# to use Puma on its own if we remove this line.
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  # Use Active Record fixture path relative to spec/ directory.
  config.fixture_paths = [Rails.root.join('spec', 'fixtures')]
  config.file_fixture_path = Rails.root.join('spec', 'fixtures', 'files')

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

  # Feature specs run multiple plays of the same track from 127.0.0.1 within
  # one example. The `ip_just_registered_this_listen?` guard would suppress
  # every play after the first and make `Listen.count` assertions unreliable.
  # The guard's behavior is covered by request specs in assets_controller_spec,
  # so disable it just for feature specs.
  config.before(:each, type: :feature) do
    allow_any_instance_of(Listens).to receive(:ip_just_registered_this_listen?).and_return(false)
  end

  config.before(:example, type: :request) do
    activate_authlogic
  end

  config.before(:example, type: :controller) do
    activate_authlogic
  end

  # # load seeds only on the feature specs
  # config.before(:suite, js: true) do
  #   Rails.application.load_seed
  # end

  config.before(:each, type: :feature, js: true) do
    @browser_console_messages = []
    messages = @browser_console_messages
    page.driver.with_playwright_page do |pw_page|
      pw_page.on('console', ->(msg) { messages << { level: msg.type, message: msg.text } })
      pw_page.on('pageerror', ->(err) { messages << { level: 'error', message: err.message } })
    end
  end

  config.after(:each, type: :feature, js: true) do |test|
    next if test.metadata[:allow_js_errors]
    aggregate_failures 'javascript errors' do
      @browser_console_messages.each do |entry|
        # Expected: validation responses for forms and Chrome's auto-logged HTTP errors are not JS errors.
        next if entry[:message].include?('422')
        next if entry[:message].include?('Failed to load resource')
        # Playlist specs cancel in-flight audio requests when switching tracks; harmless AbortError.
        next if entry[:message].include?('AbortError')

        expect(entry[:level]).not_to eq('error'), entry[:message]
        next unless entry[:level] == 'warning'
        STDERR.puts 'WARN: javascript warning'
        STDERR.puts entry[:message]
      end
    end
  end
end

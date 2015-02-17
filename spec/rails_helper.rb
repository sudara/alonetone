# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'timecop'
require 'authlogic/test_case'
require 'factory_girl_rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
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

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  module LoginHelper
    include Authlogic::TestCase

    def login(user)
      login_as = user.is_a?(User) ? user : users(user) # grab the fixture
      activate_authlogic # make authlogic happy
      expect(session = UserSession.create(login_as)).to be_truthy # make sure we logged in
      allow(controller).to receive(:current_user_session).and_return(session)
      allow(controller).to receive(:current_user).and_return(login_as) # make authlogic happy
    end

    def logout
      UserSession.find.destroy if UserSession.find
    end
  end
  config.include LoginHelper

  def pay!(subscription_type_id, item=nil)
    post "paypal/post_payment", tx: "68E56277NB6235547", st: "Completed", amt: "29.00", cc: "USD", cm: subscription_type_id, item_number: item
  end

  # Setting this config option `false` removes rspec-core's monkey patching of the
  # top level methods like `describe`, `shared_examples_for` and `shared_context`
  # on `main` and `Module`. The methods are always available through the `RSpec`
  # module like `RSpec.describe` regardless of this setting.
  # For backwards compatibility this defaults to `true`.
  #
  # https://relishapp.com/rspec/rspec-core/v/3-0/docs/configuration/global-namespace-dsl
  config.expose_dsl_globally = false
end

FactoryGirl.reload

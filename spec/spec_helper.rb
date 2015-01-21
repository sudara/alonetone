require 'rubygems'

# some nice doc/examples for rpsec 2
#
# https://gist.github.com/663876

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/mocks' 
# require 'rspec/autorun' # screws up "spring" which we now use
require 'database_cleaner'
require 'timecop'
require 'authlogic/test_case'
require 'factory_girl_rails'


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  
  # Yes, I'd like to know when my views 500
  config.render_views
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Disable transactional fixtures, and instead clean the db out 
  config.use_transactional_fixtures = false


  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  
  config.include Authlogic::TestCase
  config.include RSpec::Support::Logging
  config.include RSpec::Support::LittleHelpers

  config.before(:suite) do
     DatabaseCleaner.clean_with(:truncation)
  end
  
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  module LoginHelper
    include Authlogic::TestCase
    
    def login(user)
      login_as = user.is_a?(User) ? user : users(user) # grab the fixture
      activate_authlogic # make authlogic happy
      (session = UserSession.create(login_as)).should be_true # make sure we logged in
      controller.stub(:current_user_session).and_return(session)
      controller.stub(:current_user).and_return(login_as) # make authlogic happy
    end
    
    def logout
      UserSession.find.destroy if UserSession.find
    end
  end
  config.include LoginHelper

  def pay!(subscription_type_id, item=nil)
    post 'paypal/post_payment', :tx => '68E56277NB6235547',:st => 'Completed', :amt => '29.00',:cc => 'USD',:cm => subscription_type_id, :item_number => item 
  end
end

FactoryGirl.reload

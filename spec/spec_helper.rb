# -*- encoding : utf-8 -*-
require 'rubygems'
#require 'spork'

# some nice doc/examples for rpsec 2
#
# https://gist.github.com/663876


  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/mocks' 
  require 'rspec/autorun'
  require "authlogic/test_case"


  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # Disable transactional fixtures, and instead clean the db out 
    config.use_transactional_fixtures = true


    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
    
    config.include Authlogic::TestCase

    # config.before(:each) do 
    #   Capybara.reset_sessions!
    # end

    module LoginHelper
      include Authlogic::TestCase
      
      def login(user)
        login_as = user.is_a?(User) ? user : users(user) # grab the fixture
        activate_authlogic # make authlogic happy
        UserSession.create(login_as).should be_true # make sure we logged in
        controller.stub(:current_user_session).and_return(UserSession.create(login_as))
        #controller.stub(:current_user).and_return(login_as) # make authlogic happy
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
#end


#Spork.each_run do

  require 'factory_girl_rails'

  # This code will be run each time you run your specs.
  FactoryGirl.reload

  # Forces all threads to share the same connection, works on Capybara because it starts the web server in a thread.
  class ActiveRecord::Base
    mattr_accessor :shared_connection
    @@shared_connection = nil

    def self.connection
      @@shared_connection || retrieve_connection
    end
  end

  ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
  #end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.




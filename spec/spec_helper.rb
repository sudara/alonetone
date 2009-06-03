# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.global_fixtures = :users
  config.mock_with :mocha


  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
def login_as(user)
    request.session[:user] = user ? users(user).id : nil
  end
  
  def logout
    request.session[:user] = nil
  end
  
  def logged_in?
    request.session[:user] != nil
  end
  
  def failed_access_path
    '/' 
  end
  

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(user)
    auth_token users(user).token
  end
  
  def new_user(options = {})
    User.new({ :login      => 'beeboo', 
                  :email      => 'boo@example.com', 
                  :password   => 'quire123', 
                  :password_confirmation => 'quire123' }.merge(options))
  end
  
  def create_Contact(options = {})
    User.create({ :login      => 'quire', 
                  :email      => 'quire@example.com', 
                  :password   => 'quire', 
                  :password_confirmation => 'quire' }.merge(options))
  end
  
  def get_all_actions(cont)
    c= Module.const_get(cont.to_s.pluralize.capitalize + "Controller")
    c.public_instance_methods(false).reject{ |action| ['rescue_action'].include?(action) }
  end

  # test actions fail if not logged in
  # opts[:exclude] contains an array of actions to skip
  # opts[:include] contains an array of actions to add to the test in addition
  # to any found by get_all_actions
  def should_require_login(cont, opts={})
    except= opts[:except] || []
    actions_to_test= get_all_actions(cont).reject{ |a| except.include?(a) }
    actions_to_test += opts[:include] if opts[:include]
    actions_to_test.each do |a|
      #puts "... #{a}"
      get a
      response.should_not be_success
      response.should redirect_to('http://test.host/login')
     end
  end
  
  class BeLoggedIn
    def initialize; end
    def matches?(r)
      r.session && r.session[:user] 
    end
  
    def description
      "be logged in"
    end
  
    def failure_message
      " expected to be logged in, but was not"
    end

    def negative_failure_message
      " expected not to be logged in, but was"
    end
  end

  def be_logged_in
    BeLoggedIn.new
  end
end

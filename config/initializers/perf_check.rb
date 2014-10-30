
# config/initializers/perf_check.rb

if ENV['PERF_CHECK']
  PerfCheck::Server.authorization_action(:post, '/user_sessions') do |login, *args|
    User.send(:define_method, :valid_password?){ |*args| true }
    UserSession.create!(:login => login, :password => 'xyz', :remember_me => true)
  end
end

# Only engage this code when rails is spawned via `bundle exec perf_check`

if ENV['PERF_CHECK'] 
  PerfCheck::Server.authorization_action(:post, '/user_sessions') do |login, *args|
    
    # neuter/stub Authlogic's password check  
    User.send(:define_method, :valid_password?){ |*args| true }
  
    # special types of user, call with --admin or --super or --standard
    case login 
    when :super 
      login = User.find_by(admin: true).login
    when :admin
      login = User.find_by(moderator: true).login
    when :standard
      login = User.find_by(moderator: false, admin: false).login
    end
    
    UserSession.create!(login: login, password: 'pwnd_by_perf_check', remember_me: true)
  end
end

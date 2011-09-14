
config = Hash.new
base = File.open(File.join(Dir.pwd,'../shared/config/unicorn.conf'),"r")
base.each do |line|
  unless /\A\n|#.+/ =~ line
    config["#{line.split(/=/)[0]}"] = line.split(/=/)[1].to_s.chomp
  end
end

working_directory config['APP_ROOT']
listen config['UNICORN_SOCKET'], :backlog => 1024

worker_processes 3
timeout 300

pid config['UNICORN_PID']


logger Logger.new("log/unicorn.log")

##
# Load the app into the master before forking workers for super-fast worker spawn times
# Not good for some apps, this causes the master to use slighty more ram than a
# worker process. Otherwise it is about 14MB
# can't convert strings to booleans
##
if config['UNICORN_PRELOAD_APP'] == 'true'
  preload_app true
elsif config['UNICORN_PRELOAD_APP'] == 'false'
  preload_app false
else
  preload_app true
end

# REE - http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if config['APP_RUBY'] == 'ree'
  if GC.respond_to?(:copy_on_write_friendly=)
    GC.copy_on_write_friendly = true
  end
end

before_fork do |server, worker|
  # the following is recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  ##
  # Method for 0 Dowtime Deploys
  ##
  old_pid = "#{server.config[:pid]}.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  #Make the AR connection if defined
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  #Write the pid file for this worker
  worker_pid = File.join(File.dirname(server.config[:pid]), "unicorn_worker_#{worker.nr}.pid")
  File.open(worker_pid, "w") { |f| f.puts Process.pid }
end
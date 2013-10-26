#!/usr/bin/env puma

environment 'production'
workers 4
preload_app!
daemonize true
pidfile 'tmp/puma.pid'
stdout_redirect 'log/puma.log', 'log/puma.log', true



# The default is “tcp://0.0.0.0:9292”
# bind 'tcp://0.0.0.0:9292'

bind 'unix://tmp/puma.sock'
state_path 'tmp/puma.state'


# on_restart do
#   puts 'On restart...'
# end

# config/puma.rb
on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

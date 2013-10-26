#!/usr/bin/env puma

environment 'production'
workers 4
preload_app!
daemonize true
pidfile '/var/run/puma.pid'
stdout_redirect '/var/log/puma.log', '/var/log/puma.log', true



# The default is “tcp://0.0.0.0:9292”
# bind 'tcp://0.0.0.0:9292'

bind 'unix:///var/run/puma.sock'
state_path '/var/run/puma.state'


# on_restart do
#   puts 'On restart...'
# end

# config/puma.rb
on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

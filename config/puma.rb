#!/usr/bin/env puma

environment 'production'
workers 4
threads 1,1
preload_app!
daemonize true
pidfile 'tmp/puma.pid'
stdout_redirect 'log/puma.log', 'log/puma.log', true

bind 'unix://tmp/puma.sock'
state_path 'tmp/puma.state'

#  # Currently handled by database_connection.rb
#  on_worker_boot do
#    ActiveSupport.on_load(:active_record) do
#      ActiveRecord::Base.establish_connection
#    end
#  end

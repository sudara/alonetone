#!/usr/bin/env puma

environment 'production'
workers 4
threads 1,1
preload_app!
queue_requests false
daemonize true
pidfile 'tmp/puma.pid'
stdout_redirect 'log/puma.log', 'log/puma.log', true

bind 'unix://tmp/puma.sock'
state_path 'tmp/puma.state'

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
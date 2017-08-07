#!/usr/bin/env puma
env = ENV.fetch("RAILS_ENV") { "production" }
environment env
if env == "production"
workers 3
daemonize true
bind 'unix://tmp/puma.sock'
state_path 'tmp/puma.state'
stdout_redirect 'log/puma.log', 'log/puma.log', true
end
threads 1,4
prune_bundler
pidfile 'tmp/puma.pid'

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
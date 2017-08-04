#!/usr/bin/env puma
environment ENV.fetch("RAILS_ENV") { "production" }
if ENV.fetch("RAILS_ENV") == "production"
workers 3
daemonize true
bind 'unix://tmp/puma.sock'
state_path 'tmp/puma.state'
end
threads 1,4
prune_bundler
pidfile 'tmp/puma.pid'
stdout_redirect 'log/puma.log', 'log/puma.log', true

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
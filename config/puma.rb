#!/usr/bin/env puma
APP_ROOT = File.expand_path('..', __dir__)

env = ENV.fetch("RAILS_ENV") { "production" }
environment env

if env == "production"
  workers 3
  bind "unix://#{APP_ROOT}/tmp/puma.sock"
  state_path "#{APP_ROOT}/tmp/puma.state"
  stdout_redirect "#{APP_ROOT}/log/puma.log", "#{APP_ROOT}/log/puma.log", true
end

threads 1, 4
prune_bundler
pidfile "#{APP_ROOT}/tmp/puma.pid"

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

#!/usr/bin/env puma

environment 'production'
workers 4
preload_app!
deamonize true
pidfile

# config/puma.rb
on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
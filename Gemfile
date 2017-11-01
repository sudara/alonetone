source "https://rubygems.org"

gem "rails", "~> 5.1"
gem "mysql2"

# greenfield
gem 'greenfield', path: "greenfield"

# ruby
gem "sometimes"
gem "awesome_print", :require => 'ap'

# uploading
gem "aws-sdk", "<3.0"
gem "paperclip"
gem "ruby-mp3info", :require => 'mp3info'
gem "mime-types"
gem 'ruby-audio'
gem "s3_direct_upload"

# active record
gem "acts_as_list"
gem "has_permalink"
gem "authlogic"
gem "scrypt" # for authlogic
gem "request_store" # for authlogic
gem 'recaptcha', :require => 'recaptcha/rails'

# view
gem "redcarpet"
gem "country_select"
gem 'will_paginate'
gem 'dynamic_form'
gem 'simple_form'
gem 'local_time'
gem 'gemoji'

# temporary for rails 5 update
gem 'record_tag_helper'

# external services
gem 'rakismet'
gem 'geokit'
gem 'postmark-rails'

# greenfield
gem 'font-awesome-sass'
gem 'jquery-fileupload-rails'

gem "jquery-rails"
gem "jquery-ui-rails"
gem "sass-rails"
gem "compass-rails"
gem 'yui-compressor'
gem 'uglifier'
gem "coffee-rails"
gem "soundmanager2-rails"
gem 'turbolinks'
gem 'cloudfront-signer'


gem 'newrelic_rpm'
gem 'scout_apm'
gem 'sidekiq'
gem 'dalli'

gem 'sinatra', require: false
gem 'sinatra-contrib', require: false

group :production do
  gem 'puma'
  gem 'bugsnag'
end

group :development do
  gem 'thin'
  gem 'sqlite3'
  gem 'rack-mini-profiler'
  gem 'perf_check'
  # gem 'logical-insight'
end

## Who loves tests! You do? You do!
group :test do
  gem "rspec-rails", :require => false
  gem "rspec-mocks", :require => false
  gem "timecop", :github => 'travisjeffery/timecop', :require => false
  gem "guard-rspec", :require => false
  gem 'database_cleaner', :require => false
  gem 'rb-fsevent', '~> 0.9.1', :require => false
  gem 'guard', :github => 'sudara/guard', :require => false
  gem 'guard_listen', :github => 'sudara/listen', :require => 'guard_listen'
  # https://github.com/thoughtbot/factory_girl/wiki/Usage
  gem "factory_girl_rails",:require => false
  gem 'rails-controller-testing'
end

group :development, :test do
  gem 'pry'
end

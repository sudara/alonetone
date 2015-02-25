source "https://rubygems.org"

gem "rails", "~> 4.2"

gem "mysql2"

# greenfield
gem 'greenfield', path: "greenfield"

# temporary
gem "protected_attributes", '~> 1.0.6'

# ruby
gem "sometimes"
gem "awesome_print", :require => 'ap'

# uploading
gem "aws-sdk"
gem "paperclip"
gem "ruby-mp3info", '~> 0.7.2', :require => 'mp3info'
gem "mime-types"
gem 'ruby-audio'

# active record
gem "acts_as_list"
gem "has_permalink"
gem "authlogic"
gem "scrypt" # for authlogic
gem "request_store" # for authlogic
gem 'reportable', :git => 'git://github.com/saulabs/reportable.git', :require => 'saulabs/reportable'
gem 'recaptcha', :require => 'recaptcha/rails'

# view
gem "redcarpet"
gem "country_select"
gem 'will_paginate'
gem 'dynamic_form'
gem 'simple_form'
gem 'local_time'
gem 'gemoji'

# external services
gem 'rakismet'
gem "geokit"

# greenfield
gem 'font-awesome-sass'
gem 'jquery-fileupload-rails'

gem "jquery-rails"
gem "jquery-ui-rails"
gem "sass-rails"
gem 'compass-rails'
gem 'yui-compressor'
gem 'uglifier'
gem "coffee-rails"
gem "soundmanager2-rails"
gem 'newrelic_rpm'
gem 'bugsnag'

group :production do
  gem "puma"
  gem "skylight"
end

group :development do
  gem 'quiet_assets'
  gem 'thin'
  gem 'sqlite3'
  gem 'spring'
  gem 'rack-mini-profiler'
  gem 'perf_check'
  # gem 'logical-insight'
end

## Who loves tests! You do? You do!
group :test do
  gem "rspec-rails", :require => false
  gem "rspec-mocks", :require => false
  gem "timecop", :require => false
  gem 'guard-spring', :require => false
  gem "guard-rspec", :require => false
  gem 'database_cleaner', :require => false
  gem 'rb-fsevent', '~> 0.9.1', :require => false
  gem 'guard', :github => 'sudara/guard', :require => false
  gem 'guard_listen', :github => 'sudara/listen', :require => 'guard_listen'
  # https://github.com/thoughtbot/factory_girl/wiki/Usage
  gem "factory_girl_rails",:require => false
end

group :development, :test do
  gem 'pry'
end

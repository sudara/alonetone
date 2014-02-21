source "https://rubygems.org"

gem "rails", "4.0.2"

gem "mysql2", "0.3.11"

# temporary
gem "protected_attributes"

# ruby
gem "sometimes"
gem "awesome_print", :require => 'ap'

# uploading
gem "aws-sdk"
gem "paperclip"
gem "ruby-mp3info", :require => 'mp3info'
gem "mime-types" 

# active record
gem "acts_as_list"
gem "has_permalink"
gem "authlogic", :git => 'https://github.com/binarylogic/authlogic.git' # rails 4 fixes in master
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

# charts
gem 'groupdate', :git => 'https://github.com/L1h3r/groupdate.git' # sqlite 'support'
gem 'chartkick'

# external services
gem 'rakismet'
gem "geokit"
gem 'newrelic_rpm'
gem "skylight", "~> 0.3.0.rc"

gem "jquery-rails"
gem "jquery-ui-rails"
gem "sass-rails", "4.0.1"
gem 'compass-rails', '~> 1.1.2'
gem 'yui-compressor'
gem 'uglifier'
gem "coffee-rails"
gem "soundmanager2-rails"

group :production do
  gem "puma"      
end

group :development do
  gem 'quiet_assets'
  gem 'thin'
  gem 'sqlite3'
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
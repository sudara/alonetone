source "https://rubygems.org"

gem "rails", "~> 4.0.0"

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

# view
gem "redcarpet"
gem "country_select"
gem 'will_paginate'
gem 'dynamic_form'
gem 'simple_form'

# external services
gem 'rakismet'
gem "geokit"
gem 'newrelic_rpm'
gem 'skylight'

group :assets do
  gem "jquery-rails"
  gem "jquery-ui-rails"
  gem "sass-rails"
  gem 'compass-rails', git: 'git://github.com/milgner/compass-rails.git', branch: 'rails4'
  gem 'yui-compressor'
  gem 'uglifier'
  gem "coffee-rails"
  gem "soundmanager2-rails"
end

group :production do
  gem "puma"
  gem "mysql2"
end

group :development do
  gem "rails-footnotes"
  gem 'quiet_assets'
  gem 'rspec-rails'
  gem 'thin'
  gem 'sqlite3'
  # gem 'logical-insight'
end

## Who loves tests! You do? You do!
group :test do
  gem "rspec-rails"
  gem "rspec-mocks"
  gem "timecop"
  gem 'guard-spring'
  gem "guard-rspec"
  gem 'database_cleaner'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'guard', :github => 'sudara/guard'
  gem 'guard_listen', :github => 'sudara/listen', :require => 'guard_listen'
  # https://github.com/thoughtbot/factory_girl/wiki/Usage
  gem "factory_girl_rails"
end
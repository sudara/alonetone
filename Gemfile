source :gemcutter
gem "rails", "3.2.11"

# server
gem "mysql2"
gem "unicorn"

# uploading
gem "aws-sdk"
gem "paperclip"
gem "ruby-mp3info", "~>0.7.1", :require => 'mp3info'
gem "mime-types" 

# active record
gem "acts_as_list"
gem "has_permalink"
gem "authlogic"
gem 'reportable', :git => 'http://github.com/saulabs/reportable.git', :require => 'saulabs/reportable'

# view
gem "redcarpet"
gem "country-select"
gem 'will_paginate'
gem 'dynamic_form'
gem 'haml' # TODO: remove remaining haml, sudara hates it (requires translating about pages)

# external services
gem 'defender'
gem "geokit"
gem 'newrelic_rpm'

# console
gem "awesome_print", :require => 'ap'



group :assets do
  gem "jquery-rails"
  gem "jquery-ui-rails"
  gem "sass-rails"
  gem "compass-rails"
  gem 'yui-compressor'
  gem 'uglifier'
  gem "coffee-rails"
  gem "soundmanager2-rails"
end

group :development do
  gem "rails-footnotes"
  gem 'quiet_assets'
  gem 'thin'
end

## Who loves tests! You do? You do!
group :test do
  gem "rspec-rails"
  gem "capybara"
  gem "spork"
  gem "guard-rspec"
  gem 'database_cleaner'
  gem "guard-spork"
  # https://github.com/thoughtbot/factory_girl/wiki/Usage
  gem "factory_girl_rails"
end
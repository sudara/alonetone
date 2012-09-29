source :gemcutter
gem "rails", "3.2.8"

gem "mysql2"
gem "unicorn"

gem "aws-sdk"
gem "paperclip"

gem "authlogic"

gem "geokit"

gem "defensio"
gem "nokogiri"

gem "has_permalink"
gem "acts_as_list"
gem "redcarpet"
gem "country-select"
gem 'will_paginate'
gem "mime-types" 
gem "ruby-mp3info", "~>0.7.1", :require => 'mp3info'

# todo: remove haml, sudara hates it (requires translating about pages)
gem 'haml'
gem 'newrelic_rpm'

# allows for great console printing, easiest to specify here
gem "awesome_print", :require => 'ap'

# Remove both of these once code is relpaced with redcarpet
gem 'BlueCloth',     :require => 'bluecloth' 
gem 'hpricot' # for comment processing / markdown fixing

# this will need to be relpaced or updated, it's crufty, but used on about/stats
gem 'reportable', :git => 'http://github.com/saulabs/reportable.git', :require => 'saulabs/reportable'

group :assets do
  gem "jquery-rails"
  gem "sass-rails"
  gem "compass-rails"
  gem 'yui-compressor'
  gem 'uglifier'
  gem "coffee-rails"
end

group :development do
  # bundler requires these gems in development
  gem "rails-footnotes"
  gem 'quiet_assets'
  gem 'thin'
end

## Who loves tests! You do? You do!
group :test, :development do
  gem "rspec-rails"
  gem "capybara"
  gem "spork"
  gem "guard-rspec"
  gem 'database_cleaner'
  gem "guard-spork"
  # https://github.com/thoughtbot/factory_girl/wiki/Usage
  gem "factory_girl_rails"
end
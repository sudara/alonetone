source :gemcutter
gem "rails", "3.2.8"

gem "mysql2"
gem "unicorn"

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

# todo: remove
gem 'haml'

gem 'newrelic_rpm'


# replace with 
gem 'BlueCloth',     :require => 'bluecloth' 

gem 'hpricot' # for comment processing / markdown fixing
gem 'reportable', :git => 'http://github.com/saulabs/reportable.git', :require => 'saulabs/reportable'

group :assets do
  gem "sass-rails"
  gem 'yui-compressor'
  gem 'uglifier'
  gem "coffee-rails"
end

group :development do
  # bundler requires these gems in development
  # gem "rails-footnotes"

end

## Bundle gems used only in certain environments:
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
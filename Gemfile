source 'https://rubygems.org'

gem 'rails', '~> 5.2.2'
gem 'mysql2'
gem 'puma'

gem 'thredded'

# greenfield
gem 'greenfield', path: 'greenfield'

# ruby
gem 'sometimes'
gem 'awesome_print', require: 'ap'

# uploading
gem 'aws-sdk-s3'
gem 'paperclip', '~> 6.0.0'
gem 'rubyzip'
gem 'ruby-mp3info', require: 'mp3info'
gem 'mime-types'
gem 'ruby-audio'
gem 's3_direct_upload'

# active record
gem 'acts_as_list'
gem 'has_permalink'
gem 'authlogic'
gem 'scrypt' # for authlogic
gem 'request_store' # for authlogic

# view
gem 'redcarpet'
gem 'country_select'
gem 'dynamic_form'
gem 'simple_form'
gem 'local_time'
gem 'gemoji'
gem 'pagy'

# deprecated
gem 'record_tag_helper'

# external services
gem 'rakismet'
gem 'geokit'
gem 'postmark-rails'

# greenfield
gem 'font-awesome-sass'
gem 'jquery-fileupload-rails'

# frontend
gem 'invisible_captcha'
gem 'webpacker', '>= 4.0.x'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'sass-rails'
gem 'compass-rails'
gem 'yui-compressor'
gem 'uglifier'
gem 'coffee-rails'
gem 'soundmanager2-rails'
gem 'turbolinks'
gem 'cloudfront-signer'

# monitoring & perf
gem 'newrelic_rpm'
gem 'skylight'
gem 'sidekiq'
gem 'dalli'

group :production do
  gem 'bugsnag'
end

group :development do
  gem 'annotate'
  gem 'perf_check'
  gem 'rubocop', require: false
end

## Who loves tests! You do? You do!
group :test do
  gem 'capybara'
  gem 'chromedriver-helper'
  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'listen', require: false
  gem 'percy-capybara'
  gem 'rails-controller-testing'
  gem 'rb-fsevent', require: false
  gem 'rspec-mocks', require: false
  gem 'rspec-rails', require: false
  gem 'selenium-webdriver'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
end

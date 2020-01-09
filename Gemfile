source 'https://rubygems.org'

git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gem 'rails'
gem 'mysql2'
gem 'puma'

gem 'thredded', github: 'thredded/thredded', branch: 'collection-cache'

# ruby
gem 'sometimes'
gem 'awesome_print', require: 'ap'

# uploading
gem 'http-2' # used by AWS SDK but not in dependencies
gem 'aws-sdk-cloudfront'
gem 'aws-sdk-s3'
gem 'image_processing'
gem 'mime-types'
gem 'ruby-audio'
gem 'ruby-mp3info', require: 'mp3info'
gem 'rubyzip'
gem 's3_direct_upload'

# active record
gem 'acts_as_list'
gem 'authlogic'
gem 'scrypt' # for authlogic
gem 'request_store' # for authlogic

# view
gem 'nokogiri'
gem 'commonmarker'
gem 'country_select'
gem 'dynamic_form'
gem 'local_time'
gem 'pagy'

# external services
gem 'rakismet'
gem 'geokit'
gem 'postmark-rails'

# greenfield
gem 'font-awesome-sass'
gem 'jquery-fileupload-rails'

# frontend
gem 'webpacker'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'sass-rails'
gem 'yui-compressor'
gem 'uglifier'
gem 'coffee-rails', github: 'rails/coffee-rails'
gem 'soundmanager2-rails'
gem 'turbolinks'

# monitoring & perf
gem 'bugsnag'
gem 'newrelic_rpm'
gem 'skylight'
gem 'sidekiq'
gem 'dalli'

group :development do
  gem 'perf_check'
  gem 'annotate'
  gem 'rubocop', '0.76.0', require: false # synced to .codeclimate.yml
end

## Who loves tests! You do? You do!
group :test do
  gem 'capybara'
  gem 'webdrivers'
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

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '6.1.0.rc1'
gem 'mysql2'
gem 'puma'

gem 'thredded', github: 'sudara/thredded'

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
gem 'postmark-rails'

# frontend
gem 'webpacker'
gem 'sass-rails'
gem 'yui-compressor'
gem 'turbolinks'

# monitoring & perf
gem 'bugsnag'
gem 'oas_agent', github: 'wjessop/oas_agent'
gem 'newrelic_rpm'
gem 'skylight', '~>5.0.0.beta'
gem 'sidekiq'
gem 'dalli'

group :development do
  gem 'perf_check'
  gem 'annotate'
  gem 'rubocop', '0.87.0', require: false # synced to .codeclimate.yml
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
  gem 'rspec', require: false, github: 'rspec/rspec'
  gem 'rspec-core', require: false, github: 'rspec/rspec-core'
  gem 'rspec-expectations', require: false, github: 'rspec/rspec-expectations'
  gem 'rspec-mocks', require: false, github: 'rspec/rspec-mocks'
  gem 'rspec-support', require: false, github: 'rspec/rspec-support'
  gem 'rspec-rails', require: false, github: 'rspec/rspec-rails', branch: 'rails-6-1-dev'
  gem 'selenium-webdriver'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
end

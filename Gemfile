source 'https://rubygems.org'

git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 8.1.3'
gem 'mysql2'
gem 'puma'
gem 'puma_worker_killer'
gem 'bootsnap', require: false

# ruby
gem 'sometimes'
gem 'awesome_print', require: 'ap'

# uploading
gem 'aws-sdk-cloudfront'
gem 'aws-sdk-s3'
gem 'image_processing'
gem 'ruby-vips'
gem 'mime-types'
gem 'ruby-mp3info', require: 'mp3info'
gem 'rubyzip'

# active record
gem 'acts_as_list'
gem 'authlogic'
gem 'scrypt' # for authlogic
gem 'request_store' # for authlogic

# view
gem 'nokogiri'
gem 'commonmarker'
gem 'country_select'
gem 'local_time'
gem 'pagy', '~> 43.5'

# external services
gem 'rakismet'
gem 'postmark-rails'

# frontend
gem 'jsbundling-rails'
gem 'propshaft'
gem 'dartsass-rails'
gem 'stimulus-rails'
gem 'turbo-rails'

# monitoring & perf
gem 'bugsnag'
gem 'newrelic_rpm'
gem 'skylight'
gem 'sidekiq'
gem 'dalli'

group :development do
  gem 'perf_check', require: false
  gem 'annotaterb', require: false
  gem 'faker', require: false
  gem 'brakeman', require: false
  # Available "channels" of rubocop for code climate:
  # https://github.com/codeclimate/codeclimate-rubocop/branches/all?utf8=✓&query=channel%2Frubocop
  gem 'rubocop', require: false # synced to .codeclimate.yml
end

group :development, :test do
  gem 'debug', require: false
end

## Who loves tests! You do? You do!
group :test do
  gem 'capybara'
  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'listen', require: false
  gem "percy-capybara"
  gem 'rails-controller-testing'
  gem 'rb-fsevent', require: false
  gem 'rspec', require: false
  gem 'rspec-core', require: false
  gem 'rspec-expectations', require: false
  gem 'rspec-mocks', require: false
  gem 'rspec-support', require: false
  gem 'rspec-rails', require: false
  gem 'capybara-playwright-driver'
  gem 'webmock', require: false
end


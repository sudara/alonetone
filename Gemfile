source 'https://rubygems.org'

git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 7.2.0'
gem 'mysql2'
gem 'puma'
gem 'puma_worker_killer'

# ruby
gem 'sometimes'
gem 'awesome_print', require: 'ap'

# uploading
gem 'http-2' # used by AWS SDK but not in dependencies
gem 'aws-sdk-cloudfront'
gem 'aws-sdk-s3'
gem 'image_processing'
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
gem 'shakapacker', '~> 7.2'
gem 'sprockets-rails'
gem 'dartsass-rails'
gem 'yui-compressor'
gem 'turbo-rails'

# monitoring & perf
gem 'bugsnag'
gem 'newrelic_rpm'
gem 'skylight'
gem 'sidekiq'
gem 'dalli'
# Pinned to < 3: Rails 7.2.x's MemCacheStore still passes a positional Hash to ConnectionPool.new, which 3.0 made kwargs-only.
gem 'connection_pool', '< 3'
# Pinned to ~> 0.7.7: 0.7.5 dropped the Rack::Utils::HeaderHash reference
# that Rack 3 removed. Shakapacker's DevServerProxy middleware pulls in
# rack-proxy transitively; without this pin /packs/* requests 500 in dev.
gem 'rack-proxy', '~> 0.7.7'

group :development do
  gem 'perf_check', require: false
  gem 'annotate', require: false
  gem 'faker', require: false
  # Available "channels" of rubocop for code climate:
  # https://github.com/codeclimate/codeclimate-rubocop/branches/all?utf8=✓&query=channel%2Frubocop
  gem 'rubocop', require: false # synced to .codeclimate.yml
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

# todo, reenable test after this bug resolved:
# https://github.com/ruby/debug/issues/852
# group :development, :test do
#   gem 'debug'
# end

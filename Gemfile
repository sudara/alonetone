source 'https://rubygems.org'

git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 7.1.0'
gem 'mysql2', '0.5.6'
gem 'puma'

# ruby
# Ruby stdlib gems retired in 3.4/4.0 that some of our deps still load
# directly (not via Rails). Can drop as individual deps drop their use.
gem 'ostruct' # pulled in by json 2.x

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
gem 's3_direct_upload'

# active record
gem 'acts_as_list'
gem 'authlogic'
gem 'scrypt' # for authlogic
gem 'request_store' # for authlogic

# view
gem 'nokogiri'
gem 'commonmarker'
# 9.0+ needed for Rails 7.1: earlier versions relied on `options_for_select`
# being implicitly available inside `Tags::CountrySelect`, which Rails 7.1 broke.
gem 'country_select', '>= 9.0'
gem 'local_time'
gem 'pagy'

# external services
gem 'rakismet'
gem 'postmark-rails'

# frontend
# Pinned to 7.x: 8.x defaults to SWC/esbuild and deprioritizes Babel, which
# we still need for @babel/preset-env + core-js to support FF ESR.
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
# Pinned to < 3: connection_pool 3.0 made #initialize keyword-only, but
# Rails 7.1.x's MemCacheStore.build_mem_cache still passes positionally.
# Revisit when we upgrade Rails to a version that uses ConnectionPool.new(**opts).
gem 'connection_pool', '< 3'

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
  # 3.13+ needed for Rails 7.1: Rails added `Object#with`, which shadowed
  # RSpec's `receive(...).with(...)` in earlier versions.
  gem 'rspec-mocks', '>= 3.13', require: false
  gem 'rspec-support', require: false
  gem 'rspec-rails', require: false
  gem 'selenium-webdriver'
  gem 'webmock', require: false
end

# todo, reenable test after this bug resolved:
# https://github.com/ruby/debug/issues/852
# group :development, :test do
#   gem 'debug'
# end

source :gemcutter
gem "rails", "2.3.4"
gem "mongrel"
gem "mysql"

# bundler requires these gems in all environments
# gem "nokogiri", "1.4.2"
# gem "geokit"

gem 'aws-s3', '0.4.0', :require => 'aws/s3'

gem 'will_paginate', '~> 3.0.pre'


gem 'ruby-mp3info',  :require => 'mp3info'
gem 'rubyzip',       :require => 'zip/zip'

gem 'googlecharts',  :require => 'gchart'
gem 'haml', '2.0.9'

gem 'newrelic_rpm'
gem 'BlueCloth',     :require => 'bluecloth' 

gem 'hpricot' # for comment processing / markdown fixing

gem "rspec", ">= 1.2.0", :require => nil
gem "rspec-rails", ">= 1.2.0", :require => nil

group :production do
  gem 'rmagick'
end

group :development do
  # bundler requires these gems in development
  # gem "rails-footnotes"

end

group :test do
  # bundler requires these gems while running tests
  # gem "rspec"
  # gem "faker"
end
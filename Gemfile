source :gemcutter
gem "rails", "2.3.14"
#gem "mongrel", :require => nil
#gem "mongrel_cluster"
gem "mysql2", "~> 0.2.7"

gem "unicorn"

# bundler requires these gems in all environments
gem "nokogiri"

# gem "geokit"

gem 'aws-s3', '~>0.5.0', :require => 'aws/s3'

gem 'will_paginate', '~> 2.3.14'

gem "mime-types" 
gem 'ruby-mp3info',  :require => 'mp3info'
gem 'rubyzip',       :require => 'zip/zip'

gem 'googlecharts',  :require => 'gchart'
gem 'haml', '2.0.9'

gem 'newrelic_rpm'
gem 'BlueCloth',     :require => 'bluecloth' 

gem 'hpricot' # for comment processing / markdown fixing

gem "rspec", ">= 1.2.0", :require => nil
gem "rspec-rails", ">= 1.2.0", :require => nil

gem 'reportable', :git => 'http://github.com/saulabs/reportable.git', :require => 'saulabs/reportable'


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

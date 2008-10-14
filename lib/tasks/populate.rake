# Borrow & modified from spot-us
namespace :db do
  desc "Loads initial database models for the current environment."
  task :populate => :environment do
    require 'active_record/fixtures'

    puts "Populating data"

    # load .yml files
    Dir[File.join(RAILS_ROOT, 'db', 'fixtures', '*.yml')].sort.each { |fixture| 
      puts "Loading #{fixture}"
      Fixtures.create_fixtures('db/fixtures', File.basename(fixture, '.*'))
    }
    
    # load .rb files
    Dir[File.join(RAILS_ROOT, 'db', 'fixtures', '*.rb')].sort.each { |fixture| 
      puts "Loading #{fixture}"
      load fixture
    }
  end
end
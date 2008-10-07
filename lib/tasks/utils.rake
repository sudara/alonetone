namespace :db do
  desc "Re-create the database and do all migrations"
  task :restart => ['db:drop', 'db:create', 'db:migrate']#, 'spec:db:fixtures:load', 'db:test:clone'] 
end

namespace :spec do
  desc "Generate rspec document in HTML format"
  task :html_doc => :environment do
    require 'rake'
    require 'spec/rake/verify_rcov'

    RCov::VerifyTask.new(:verify_rcov => :spec) do |t|
      t.threshold = 100.0 # Make sure you have rcov 0.7 or higher!
      t.index_html = '../doc/output/coverage/index.html'
    end
  end
end

##
# The Index Inspector
# http://code.new-bamboo.co.uk/
namespace :db do
  desc "LOADER: Discover indexes etc that might be good to add" 
  task :inspect => :environment do
    cnx = ActiveRecord::Base.connection
    cnx.tables.each do |table|
      puts "# #{table}"
      puts '# ==='
      begin
        klass = table.singularize.camelize.constantize 
      rescue
        puts "# uninitialized constant #{table.singularize.camelize}, consider dropping #{table}"
        puts "# drop_table #{table}"
        puts ""
        next
      end
      
      puts '# indexes'
      puts '==='
      indexes = cnx.execute("show indexes from #{table};")
      index_names = []
      indexes.each do |r|
        index_names << r[4]
        puts "#" + r.inspect unless r[2] == "PRIMARY"
      end
      
      suggested_indexes = []
      puts "#   columns"
      puts "#   ==="
      klass.columns.each do |column|
        gap = " " * (30 - column.name.length)
        puts "#     #{column.name} #{gap} #{column.sql_type}"
        if !index_names.include?(column.name)
          suggested_indexes << column
        end
      end
      puts ""
      
      puts "#   suggested indexes"
      puts "#   ==="
      
      suggested_indexes.each do |index|
        line = "     add_index :#{table}, :#{index.name}"
        puts index.name =~ /_type$|type$|_id|_at$|_on/ ? "#{line}" : "##{line}"
      end
      puts ""
      
    end
  end
end
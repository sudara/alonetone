namespace :kropper do
  PLUGIN_ROOT = File.dirname(__FILE__) + '/../'
  
  desc "Installs the kropper images, stylesheets and javascripts"
  task :install => ["kropper:install:images", "kropper:install:stylesheets", "kropper:install:javascripts"]
  
  namespace :install do

    desc "Install kropper images into RAILS_ROOT/public/images/kropper"
    task :images do
      FileUtils.mkdir RAILS_ROOT + '/public/images/kropper' unless File.exists?(RAILS_ROOT + '/public/images/kropper')
      FileUtils.cp Dir[PLUGIN_ROOT + '/assets/images/kropper/*.{gif,png}'], RAILS_ROOT + '/public/images/kropper'
    end

    desc "Install kropper images into RAILS_ROOT/public/stylesheets"
    task :stylesheets do
      FileUtils.cp Dir[PLUGIN_ROOT + '/assets/stylesheets/*.css'], RAILS_ROOT + '/public/stylesheets'
    end

    desc "Install kropper images into RAILS_ROOT/public/javascripts"
    task :javascripts do
      FileUtils.cp Dir[PLUGIN_ROOT + '/assets/javascripts/*.js'], RAILS_ROOT + '/public/javascripts'
    end

  end
end
require 'rake'

desc "Setup alonetone from scratch (copy config, create/seed db)"
task :setup => [:copy_config, :environment, 'db:setup']


desc "Copy application sample config for dev/test purposes"
task :copy_config do
  if Rails.env.development? or Rails.env.test?
    
    %w[alonetone database newrelic].each do |settings|
      settings_file         = File.join(Rails.root, *%W(config #{settings}.yml))
      settings_file_example = File.join(Rails.root, *%W(config #{settings}.example.yml))

      unless File.exist?(settings_file)
        puts "Setting up config/#{settings}.yml from config/#{settings}.example.yml..."
        FileUtils.cp(settings_file_example, settings_file)
      end
    end
  end
end

 
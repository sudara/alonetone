require 'rake'

desc "Setup Alonetone: copy configuration examples, create JS stubs, and setup database."
task setup: %w[setup:copy_config setup:touch_js db:setup]

namespace :setup do
  desc "Copy application sample config for development and test purposes"
  task :copy_config do
    if Rails.env.development? || Rails.env.test?

      %w[alonetone database newrelic].each do |settings|
        settings_file = File.join(Rails.root, "config", "#{settings}.yml")
        settings_file_example = File.join(Rails.root, "config", "#{settings}.example.yml")

        unless File.exist?(settings_file)
          puts "Setting up config/#{settings}.yml from config/#{settings}.example.yml..."
          FileUtils.cp(settings_file_example, settings_file)
        end
      end
    end
  end

  desc "Touch JavaScript stubs to make Webpacker run without errors"
  task touch_js: :environment do
    FileUtils.touch(Rails.root.join("app", "javascript", "animation", "MorphSVGPlugin.js"))
  end
end

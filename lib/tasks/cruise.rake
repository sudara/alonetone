desc 'Continuous build target'

task :cruise do
  # Force db:migrate
  ENV['RAILS_ENV'] = 'test'
  Rake::Task["db:migrate"].invoke
  
  out = ENV['CC_BUILD_ARTIFACTS']
  mkdir_p out unless File.directory? out if out
  
  # publish blog
  sh "/usr/bin/redcloth BLOG.textile > BLOG.html; mv BLOG.html #{out}" if out

  # Relocates the coverage folder to make it a visible custom build artifact in CruiseControl
  Rake::Task["spec:rcov"].invoke
  mv 'coverage', "#{out}/spec_coverage" if out
end
namespace :db do
  desc 'Drops, creates, migrates & populates.'
  task :remake => [:drop, :create, :migrate, :populate]
end

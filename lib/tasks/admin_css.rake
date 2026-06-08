namespace :admin_css do
  desc "Build the isolated Tailwind admin stylesheet"
  task :build do
    sh "yarn build:admin-css"
  end
end

# Propshaft defines assets:precompile via its railtie before app lib/tasks load,
# so this enhancement reliably runs the admin build on deploy.
Rake::Task["assets:precompile"].enhance(["admin_css:build"]) if Rake::Task.task_defined?("assets:precompile")

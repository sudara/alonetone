namespace :admin_assets do
  desc "Build the isolated Tailwind admin stylesheet and admin JS bundle"
  task :build do
    sh "yarn build:admin-css"
    sh "yarn build:admin-js"
  end
end

# Propshaft defines assets:precompile via its railtie before app lib/tasks load,
# so this enhancement reliably runs the admin build on deploy. jsbundling's own
# hook only runs `yarn build` (application.js), which skips admin.js entirely.
Rake::Task["assets:precompile"].enhance(["admin_assets:build"]) if Rake::Task.task_defined?("assets:precompile")

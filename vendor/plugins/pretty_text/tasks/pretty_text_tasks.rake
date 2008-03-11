# desc "Explaining what the task does"
# task :pretty_text do
#   # Task goes here
# end
namespace :pretty_text do
  
  desc "Clean up pretty_text directory forcing all images to be regenerated"
  task :clear do
    rm File.join(RAILS_ROOT, 'public/images/pretty_text/*')
  end
  
end
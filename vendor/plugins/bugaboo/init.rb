# Include hook code here

require 'bugaboo'

#ActionController::Routing::Routes.add_named_route(:controller => :bugaboo, 'bugaboo')
#ActionController::Routing::Routes.reload!

# remove when plugin is functional and/or production
Dependencies.load_once_paths.delete(lib_path)

# ActionController::Base.view_paths.unshift File.join(directory, 'views')

# let the app find our partial

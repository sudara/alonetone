# Include hook code here
require 'image'
require 'pretty_text'

# Include the pretty_text helper
ActionView::Base.send :include, Sudara::PrettyText

# Include the pretty_text monster test controller
PrettyTextTestsController.view_paths = [File.join(directory, 'views')]


# setup public/images/pretty_text 
FileUtils.mkdir(Sudara::PrettyText::Image.pretty_text_path) unless File.exists? Sudara::PrettyText::Image.pretty_text_path

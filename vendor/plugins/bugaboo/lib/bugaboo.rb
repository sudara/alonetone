# Bugaboo
require 'bugaboo/view_helpers'
ActionView::Base.class_eval { include Bugaboo::ViewHelpers }

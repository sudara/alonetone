class Stalking < ActiveRecord::Base

  belongs_to :stalker, :class_name => 'User'  
  belongs_to :stalkee, :class_name => 'User'

end
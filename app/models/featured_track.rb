class FeaturedTrack < ActiveRecord::Base
  
  belongs_to :feature
  belongs_to :asset
  acts_as_list :scope => :feature_id, :order => :position

end

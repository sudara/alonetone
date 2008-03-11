class FacebookAccount < ActiveRecord::Base
  has_many :facebook_addables
  has_many :assets, :through => :facebook_addables, :source => :asset,
                      :conditions => "facebook_addables.profile_chunk_type = 'Asset'"
end

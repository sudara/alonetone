class FeaturedTrack < ActiveRecord::Base
  belongs_to :feature
  belongs_to :asset
  acts_as_list scope: :feature_id, order: :position
end

# == Schema Information
#
# Table name: featured_tracks
#
#  id         :integer          not null, primary key
#  position   :integer          default(1)
#  created_at :datetime
#  updated_at :datetime
#  asset_id   :integer
#  feature_id :integer
#

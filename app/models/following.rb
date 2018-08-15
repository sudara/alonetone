# == Schema Information
#
# Table name: followings
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  follower_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Following < ActiveRecord::Base
  belongs_to :user, counter_cache: :followers_count
  belongs_to :follower, class_name: 'User'

  validates_presence_of :user_id, :follower_id
end

# == Schema Information
#
# Table name: followings
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  follower_id :integer
#  user_id     :integer
#
# Indexes
#
#  index_followings_on_follower_id  (follower_id)
#  index_followings_on_user_id      (user_id)
#

class Membership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
end

# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  admin      :boolean
#  created_at :datetime
#  updated_at :datetime
#  group_id   :integer
#  user_id    :integer
#

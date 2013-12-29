class Following < ActiveRecord::Base

  belongs_to :user, :counter_cache => :followers_count 
  belongs_to :follower, :class_name => 'User'

  validates_presence_of :user_id, :follower_id
  attr_accessible :user_id, :follower_id
end

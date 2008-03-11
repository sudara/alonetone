# == Schema Information
# Schema version: 16
#
# Table name: listens
#
#  id         :integer(11)   not null, primary key
#  asset_id   :integer(11)   
#  user_id    :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Listen < ActiveRecord::Base
  
  # A "Listen" occurs when a user listens to another users track
  belongs_to :asset, :counter_cache => true
  
  belongs_to :listener, :class_name => 'User'
  belongs_to :track_owner, :class_name => 'User', :counter_cache => true
  
  validates_presence_of :asset_id, :track_owner_id
  
  def source
    self[:source] || 'alonetone'
  end
  
end

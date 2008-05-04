# == Schema Information
# Schema version: 16
#
# Table name: tracks
#
#  id          :integer(11)   not null, primary key
#  playlist_id :integer(11)   
#  asset_id    :integer(11)   
#  position    :integer(11)   
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Track < ActiveRecord::Base
  belongs_to :playlist, :counter_cache => true
  belongs_to :asset
  belongs_to :user
  
  named_scope :favorites, {:select => 'DISTINCT assets.*, tracks.*', :conditions => ['is_favorite = ?',true], :order => 'tracks.created_at DESC', :joins => :asset}


  acts_as_list :scope => :playlist_id, :order => :position
  
  validates_presence_of :asset_id, :playlist_id
  
  # allow us to pretend that the track has info by forwarding to the asset
  [:length, :name].each do |attribute|
    define_method("#{attribute}?") { self.track.send("#{attribute}") }
  end
end

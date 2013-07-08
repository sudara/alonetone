# -*- encoding : utf-8 -*-
class Playlist < ActiveRecord::Base
  
  acts_as_list :scope => :user_id, :order => :position

  scope :mixes,            where(:is_mix => true)
  scope :albums,           where(:is_mix => false).where(:is_favorite => false)
  scope :favorites,        where(:is_favorite => true)
  scope :public,           where(:private => false).where(:is_favorite => false).where("tracks_count > 1") 
  scope :include_private,  where(:is_favorite => false)
  scope :recent,           order('playlists.created_at DESC')
  scope :for_home,     recent.public.limit(12).includes(:user, :pic)

  belongs_to :user, :counter_cache => true  
  has_one  :pic, :as => :picable, :dependent => :destroy
  has_many :tracks, :include => [:asset => :user], :dependent => :destroy, :order => :position
  has_many :assets, :through => :tracks #, :after_add => 
  
  validates_presence_of :title
  validates_length_of   :title, :within => 4..100
  validates_length_of   :year, :within => 2..4, :allow_blank => true
  validates_presence_of :description
  validates_length_of   :description, :within => 1..2000, :allow_blank => true
  
  has_permalink :title
  
  # make sure we update permalink when user changes title
  before_validation  :auto_name_favorites, :on => :create
  before_save  :create_unique_permalink
  before_update :set_mix_or_album

  def to_param
    "#{self.permalink}"
  end
  
  def dummy_pic(size)
    case size
      when :small then 'no-cover-50.jpg' 
      when :large then 'no-cover-125.jpg'
      when :album then 'no-cover-200.jpg' 
      when nil then 'no-cover-400.jpg'
    end 
  end
  
  def type
    is_mix? ? 'mix' : 'album'
  end
  
  def cover(size=nil)
    return dummy_pic(size) unless self.pic && !self.pic.new_record?
    self.pic.pic.url(size)
  end
  
  def has_tracks?
    (self.tracks_count || 0) > 0
  end

  def empty?
    !has_tracks?
  end
  
  def play_time
    total_track_length = tracks.inject(0) do |total, track| 
      total += track.asset_length || 0
    end
    Asset.formatted_time(total_track_length)
  end
  
  def self.latest(limit=5)
    self.where('playlists.tracks_count > 0').includes(:user).limit(limit).order('playlists.created_at DESC')
  end
  
   
  
  # playlist is a mix if there is at least one track with a track from another user  
  def set_mix_or_album
    # is this a favorites playlist?
    is_mix = true if is_favorite? and return true
    is_mix = true if tracks.present? && tracks.count > tracks.count(:all, :conditions => ['user_id != ?',user.id])
    true
  end
  
  # if this is a "favorites" playlist, give it a name/description to match
  def auto_name_favorites
    self.title = self.description = self.user.name + "'s Favorite tracks on alonetone" \
    if self.is_favorite?
  end
end

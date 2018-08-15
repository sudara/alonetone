# == Schema Information
#
# Table name: playlists
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  description  :text(16777215)
#  image        :string(255)
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#  pic_id       :integer
#  permalink    :string(255)
#  tracks_count :integer          default(0)
#  is_mix       :boolean
#  private      :boolean
#  is_favorite  :boolean          default(FALSE)
#  year         :string(255)
#  position     :integer          default(1)
#  link1        :string(255)
#  link2        :string(255)
#  link3        :string(255)
#  credits      :text(16777215)
#  has_details  :boolean          default(FALSE)
#  theme        :string(255)
#

class Playlist < ActiveRecord::Base
  acts_as_list :scope => :user_id, :order => :position

  scope :mixes,            -> { where(:is_mix => true)                                                            }
  scope :albums,           -> { where(:is_mix => false).where(:is_favorite => false)                              }
  scope :favorites,        -> { where(:is_favorite => true)                                                       }
  scope :only_public,      -> { where(:private => false).where(:is_favorite => false).where("tracks_count > 1")   }
  scope :include_private,  -> { where(:is_favorite => false)                                                      }
  scope :recent,           -> { order('playlists.created_at DESC')                                                }
  scope :with_pic,         -> { preload(:pic)                                                                     }
  scope :for_home,         -> { select('distinct playlists.user_id, playlists.*').recent.only_public.with_pic.includes(:user)                              }

  belongs_to :user, :counter_cache => true
  has_one  :pic, :as => :picable, :dependent => :destroy
  has_many :tracks,
     -> {order(:position).includes(:asset => :user)},
     :dependent => :destroy
  has_many :assets, :through => :tracks
  has_many :public_assets,
    -> { where('assets.private = ?', false)},
    :through => :tracks, :source => :asset

  has_many :greenfield_downloads, class_name: '::Greenfield::PlaylistDownload', :dependent => :destroy
  accepts_nested_attributes_for :greenfield_downloads

  validates_presence_of :description, :title, :user_id
  validates_length_of   :title, :within => 4..100
  validates_length_of   :year, :within => 2..4, :allow_blank => true
  validates_length_of   :description, :within => 1..2000, :allow_blank => true

  has_permalink :title
  before_validation  :name_favorites_and_set_permalink, :on => :create
  before_update :set_mix_or_album
  before_update :ensure_private_if_less_than_two_tracks

  def to_param
    "#{permalink}"
  end

  def dummy_pic(size)
    case size
      when :small then 'default/no-cover-50.jpg'
      when :large then 'default/no-cover-125.jpg'
      when :album then 'default/no-cover-200.jpg'
      else 'default/no-cover-200.jpg'
    end
  end

  def type
    is_mix? ? 'mix' : 'album'
  end

  def cover(size=nil)
    return dummy_pic(size) if has_no_cover?
    self.pic.pic.url(size)
  end

  def has_no_cover?
     Alonetone.try(:default_user_images) or !self.pic.present? or self.pic.new_record? or !self.pic.try(:pic).present?
  end

  def has_tracks?
    (self.tracks_count || 0) > 0
  end

  def has_any_links?
    link1.present? || link2.present? || greenfield_downloads.present?
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

  def ensure_private_if_less_than_two_tracks
    self.private = true if !is_favorite? and tracks_count < 2
    true
  end

  # playlist is a mix if there is at least one track with a track from another user
  def set_mix_or_album
    # is this a favorites playlist?
    is_mix = true if is_favorite?
    is_mix = true if tracks.present? && tracks.count > tracks.where('user_id != ?',user.id).count
    true
  end

  # if this is a "favorites" playlist, give it a name/description to match
  def name_favorites_and_set_permalink
    self.title = self.description = self.user.name + "'s favorite tracks" if self.is_favorite?
    generate_permalink!
  end
end

# == Schema Information
#
# Table name: playlists
#
#  id           :integer          not null, primary key
#  credits      :text(16777215)
#  description  :text(16777215)
#  has_details  :boolean          default(FALSE)
#  image        :string(255)
#  is_favorite  :boolean          default(FALSE)
#  is_mix       :boolean
#  link1        :string(255)
#  link2        :string(255)
#  link3        :string(255)
#  permalink    :string(255)
#  position     :integer          default(1)
#  private      :boolean
#  theme        :string(255)
#  title        :string(255)
#  tracks_count :integer          default(0)
#  year         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  pic_id       :integer
#  user_id      :integer
#
# Indexes
#
#  index_playlists_on_permalink  (permalink)
#  index_playlists_on_position   (position)
#  index_playlists_on_user_id    (user_id)
#

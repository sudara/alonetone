# == Schema Information
#
# Table name: tracks
#
#  id          :integer          not null, primary key
#  playlist_id :integer
#  asset_id    :integer
#  position    :integer          default(1)
#  created_at  :datetime
#  updated_at  :datetime
#  is_favorite :boolean          default(FALSE)
#  user_id     :integer
#

class Track < ActiveRecord::Base
  belongs_to :playlist, counter_cache: true, touch: true
  belongs_to :asset
  belongs_to :user

  scope :recent, -> { order('tracks.created_at DESC') }
  scope :favorites, -> { where(is_favorite: true).recent }
  scope :favorites_for_home, -> { favorites.limit(5).includes({ user: :pic }, asset: { user: :pic }) }

  delegate :length, :name, to: :asset
  acts_as_list scope: :playlist_id, order: :position

  before_validation :ensure_playlist_if_favorite
  validates_presence_of :asset_id, :playlist_id, :user_id

  def asset_length
    asset ? asset[:length] : 0
  end

  def self.most_favorited(limit = 10, offset = 0)
    count(:all,
          conditions: ['tracks.is_favorite = ?', true],
          group: 'asset_id',
          order: 'count_all DESC',
          limit: limit,
          offset: offset).collect(&:first)
  end

  def ensure_playlist_if_favorite
    self.playlist_id = Playlist.favorites.where(user_id: user_id).first_or_create.id if is_favorite?
    true
  end
end

class Track < ActiveRecord::Base
  belongs_to :playlist, counter_cache: true, touch: true
  belongs_to :asset
  belongs_to :user

  scope :recent, -> { order('tracks.created_at DESC') }
  scope :favorites, -> { where(is_favorite: true).recent }
  scope :of_other_users, -> { joins(:asset).where('assets.user_id != tracks.user_id') }
  scope :favorites_for_home, -> { favorites.of_other_users.includes({ user: :pic }, asset: { user: :pic }).limit(5) }

  delegate :length, :name, to: :asset
  acts_as_list scope: :playlist_id, order: :position

  before_validation :ensure_playlist_if_favorite, :set_user_id_from_playlist
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

  def set_user_id_from_playlist
    self.user_id ||= Playlist.find(playlist_id).user_id
  end

  def ensure_playlist_if_favorite
    self.playlist_id = Playlist.favorites.where(user_id: user_id).first_or_create.id if is_favorite?
    true
  end
end

# == Schema Information
#
# Table name: tracks
#
#  id          :integer          not null, primary key
#  is_favorite :boolean          default(FALSE)
#  position    :integer          default(1)
#  created_at  :datetime
#  updated_at  :datetime
#  asset_id    :integer
#  playlist_id :integer
#  user_id     :integer
#
# Indexes
#
#  index_tracks_on_asset_id     (asset_id)
#  index_tracks_on_is_favorite  (is_favorite)
#  index_tracks_on_playlist_id  (playlist_id)
#  index_tracks_on_user_id      (user_id)
#

class Playlist < ActiveRecord::Base
  include SoftDeletion

  acts_as_list scope: :user_id, order: :position, add_new_at: :top

  scope :albums,           -> { where(is_mix: false).where(is_favorite: false) }
  scope :favorites,        -> { where(is_favorite: true) }
  scope :for_home,         -> { select('distinct playlists.user_id, playlists.*').recently_published.only_public.with_preloads }
  scope :include_private,  -> { where(is_favorite: false) }
  scope :mixes,            -> { where(is_mix: true) }
  scope :only_public,      -> { where(private: false).where(is_favorite: false) }
  scope :with_preloads,    -> { preload(:cover_image_blob, user: { avatar_image_attachment: :blob }) }
  scope :recently_published, -> { reorder('playlists.published_at DESC') }

  belongs_to :user, counter_cache: true
  has_many :tracks,
     -> { order(:position).includes(asset: :user) },
     dependent: :destroy
  has_many :assets, through: :tracks
  has_many :public_assets,
    -> { where('assets.private = ?', false) },
    through: :tracks, source: :asset

  validates_presence_of :title, :user_id
  validates_length_of   :title, within: 3..100
  validates_length_of   :year, within: 2..4, allow_blank: true

  has_permalink :title
  before_validation :name_favorites_and_set_permalink, on: :create
  before_update :check_for_new_permalink, :ensure_private_if_less_than_two_tracks,
    :set_published_at, :notify_followers_if_publishing_album

  # We have to define attachments last to make the Active Record callbacks
  # fire in the right order.
  has_one_attached :cover_image

  enum(
    cover_quality: {
      ancient: 0,
      legacy: 1,
      modern: 2
    },
    _suffix: true
  )

  def to_param
    permalink.to_s
  end

  def type
    is_mix? ? 'mix' : 'album'
  end

  def has_tracks?
    (tracks_count || 0) > 0
  end

  # Returns true when the playlist may be publicly viewed.
  def public?
    !private && !is_favorite && has_tracks?
  end

  def has_any_links?
    link1.present? || link2.present?
  end

  def is_album_with_only_private_tracks?
    # we only care about completely unpublished albums
    !is_mix? && assets.pluck(:private).uniq == [true]
  end

  def quietly_publish_assets!
    # bypasses the after_create on assets that sends out email
    assets.update_all(private: false)
  end

  def publishing?
    # it's not publishing if someone marked it private and then public again
    private_changed? && (private_was == true) && published_at_was.nil?
  end

  def set_published_at
    self.published_at = Time.zone.now if publishing? && can_be_public?
  end

  def notify_followers
    user.followers.select(&:wants_email?).each do |user|
      AlbumNotificationJob.perform_later(id, user.id)
    end
  end

  def notify_followers_if_publishing_album
    quietly_publish_assets! && notify_followers if publishing? && is_album_with_only_private_tracks?
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

  # Returns true when the playlist has a usable cover image.
  def cover_image_present?
    cover_image.attached?
  end

  # Generates a location to playlist's cover with the requested variant. Returns nil when the
  # playlist does not have a usable cover.
  def cover_image_location(variant:)
    return unless cover_image.attached?

    Storage::Location.new(
      ImageVariant.variant(cover_image, variant: variant),
      signed: false
    )
  end

  def self.latest(limit = 5)
    where('playlists.tracks_count > 0').includes(:user).limit(limit).order('playlists.created_at DESC')
  end

  def ensure_private_if_less_than_two_tracks
    self.private = true if !is_favorite? && !can_be_public?
    true
  end

  # list any required conditions before playlist
  # can be made public
  def can_be_public?
    tracks_count >= 2
  end

  # if this is a "favorites" playlist, give it a name/description to match
  def name_favorites_and_set_permalink
    self.title = user.name + "'s favorite tracks" if is_favorite?
    # move me to new tracks_controller#create
    self.is_mix = true if consider_a_mix?

    generate_permalink!
  end

  def check_for_new_permalink
    generate_permalink! if title_changed?
  end

  def consider_a_mix?
    return true if is_favorite?

    tracks.present? && tracks.pluck(:user_id).uniq.count > 1
  end
end

# == Schema Information
#
# Table name: playlists
#
#  id            :integer          not null, primary key
#  cover_quality :integer          default("modern")
#  credits       :text(4294967295)
#  deleted_at    :datetime
#  has_details   :boolean          default(FALSE)
#  image         :string(255)
#  is_favorite   :boolean          default(FALSE)
#  is_mix        :boolean
#  link1         :string(255)
#  link2         :string(255)
#  link3         :string(255)
#  permalink     :string(255)
#  position      :integer          default(1)
#  private       :boolean
#  published_at  :datetime
#  theme         :string(255)
#  title         :string(255)
#  tracks_count  :integer          default(0)
#  year          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  user_id       :integer
#
# Indexes
#
#  index_playlists_on_permalink  (permalink)
#  index_playlists_on_position   (position)
#  index_playlists_on_user_id    (user_id)
#

class Playlist < ActiveRecord::Base
  include SoftDeletion

  acts_as_list scope: :user_id, order: :position, add_new_at: :top

  scope :albums,           -> { where(is_mix: false).where(is_favorite: false) }
  scope :favorites,        -> { where(is_favorite: true) }
  scope :for_home,         -> { select('distinct playlists.user_id, playlists.*').recently_published.only_public.with_preloads }
  scope :include_private,  -> { where(is_favorite: false) }
  scope :mixes,            -> { where(is_mix: true) }
  scope :only_public,      -> { where(published: true).where(is_favorite: false) }
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

  before_validation :name_favorites, on: :create
  before_update(
    :check_visibility,
    :notify_followers_if_publishing_album
  )

  # We have to define attachments last to make the Active Record callbacks
  # fire in the right order.
  has_one_attached :cover_image
  validates :cover_image, attached: {
    content_type: %w[image/png image/jpeg image/jpg image/gif],
    byte_size: { less_than: 20.megabytes }
  }, if: :cover_image_present?

  enum(
    cover_quality: {
      ancient: 0,
      legacy: 1,
      modern: 2
    },
    _suffix: true
  )

  include Slugs
  has_slug(
    :permalink,
    from_attribute: :title,
    scope: :user_id,
    default: 'untitled'
  )

  def to_param
    permalink
  end

  def type
    is_mix? ? 'mix' : 'album'
  end

  def has_tracks?
    (tracks_count || 0) > 0
  end

  def publishing?
    # it's not publishing if someone marked it private and then public again
    published_changed? && (published_was == false) && published_at_was.nil?
  end

  def publishable?
    tracks_count >= 2
  end

  # This will be read by the UI
  def is_private?
    !published?
  end

  def is_private=(value)
    return if value.nil?

    self.published = value # cast to boolean
    self.published = !published # store the opposite value as .published?
    save
  end

  def check_visibility
    if publishing? && publishable?
      publish
    elsif publishing? && !publishable?
      self.published = false
    end
  end

  def publish
    self.published_at = Time.zone.now
    self.published = true
  end

  def publish!
    publish && save!
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

  def notify_followers
    user.followers.includes(:settings).where('settings.email_new_tracks = ?', true).each do |user|
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
  #
  # As of Rails 6.0 attachables aren't persisted to storage until save
  # https://github.com/rails/rails/pull/33303
  # Which means we don't want to try and display variants from unpersisted records with invalid attachments
  def cover_image_location(variant:)
    return unless cover_image.attached? && cover_image.persisted?

    Storage::Location.new(
      ImageVariant.variant(cover_image, variant: variant),
      signed: false
    )
  end

  def self.latest(limit = 5)
    where('playlists.tracks_count > 0').includes(:user).limit(limit).order('playlists.created_at DESC')
  end

  # if this is a "favorites" playlist, give it a name/description to match
  def name_favorites
    self.title = user.name + "'s favorite tracks" if is_favorite?
    # move me to new tracks_controller#create
    self.is_mix = true if consider_a_mix?
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

# frozen_string_literal: true

# An asset represents an audio track.
class Asset < ApplicationRecord
  include SoftDeletion

  require_dependency 'asset/radio'
  require_dependency 'asset/statistics'
  require_dependency 'asset/waveform'

  include Asset::Radio
  include Asset::Statistics
  include Asset::Waveform

  has_rich_text :post

  attribute :user_agent, :string
  serialize :waveform, Array

  scope :published,       -> { where(private: false) }
  scope :recent,          -> { reorder('assets.id DESC').includes(:user) }
  scope :last_updated,    -> { reorder('updated_at DESC').first }
  scope :random_order,    -> { reorder(Arel.sql('RAND()')) }
  scope :favorited,       -> { select('distinct assets.*').includes(:tracks).where('tracks.is_favorite = (?)', true).reorder('tracks.id DESC') }
  scope :not_current,     ->(id) { where('id != ?', id) }
  scope :for_user,        ->(user_id) { where(user_id: user_id) }
  scope :hottest,         -> { where('hotness > 0').reorder(hotness: :desc) }
  scope :most_commented,  -> { where('comments_count > 0').reorder('comments_count DESC') }
  scope :most_listened,   -> { where('listens_count > 0').reorder('listens_count DESC') }
  scope :with_preloads,   -> { with_rich_text_post_and_embeds.includes(user: { avatar_image_attachment: :blob }) }

  belongs_to :user
  after_commit :update_user_assets_count, on: :create

  belongs_to :possibly_deleted_user,
    -> { with_deleted },
    class_name: 'User',
    foreign_key: 'user_id'

  has_one :audio_feature, dependent: :destroy
  accepts_nested_attributes_for :audio_feature
  has_many :tracks,    dependent: :destroy
  has_many :playlists, through: :tracks
  has_many :listens,   -> { order('listens.created_at DESC') }, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :listeners,
    -> { distinct.order('listens.created_at DESC') },
    through: :listens

  has_many :favoriters,
    -> { where('tracks.is_favorite' => true).order('tracks.created_at DESC') },
    source: :user,
    through: :tracks

  after_commit :create_waveform, on: :create

  # We have to define attachments last to make the Active Record callbacks
  # fire in the right order.
  has_one_attached :audio_file

  include Rakismet::Model
  rakismet_attrs  author: proc { user.name },
                  author_email: proc { user.email },
                  content: proc { description },
                  permalink: proc { full_permalink },
                  user_role: proc { role },
                  comment_type: 'mp3-post' # this can't be "mp3", it calls paperclip

  validates :user, presence: true
  validates :audio_file, attached: {
    content_type: %w[audio/mpeg audio/mp3 audio/x-mp3],
    byte_size: { less_than: 60.megabytes }
  }

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

  # @deprecated Please use asset.audio_file.filename.
  def mp3_file_name
    if filename = audio_file&.filename
      filename.to_s
    end
  end

  # @deprecated Please use asset.audio_file.byte_size.
  def mp3_file_size
    audio_file.attached? ? audio_file.byte_size : nil
  end

  # @deprecated Please use asset.audio_file.content_type.
  def mp3_content_type
    audio_file.attached? ? audio_file.content_type : nil
  end

  def self.latest(limit = 10)
    with_preloads.limit(limit).order('assets.created_at DESC')
  end

  def self.id_not_in(asset_ids)
    if asset_ids.present?
      where("assets.id NOT IN (?)", asset_ids)
    else
      all
    end
  end

  def self.user_id_in(user_ids)
    where("assets.user_id IN (?)", user_ids)
  end

  def self.conditions_by_like(value)
    conditions = ['assets.title', 'assets.description', 'assets.mp3_file_name'].collect do |c|
      "#{c} LIKE " + ActiveRecord::Base.connection.quote("%#{value}%")
    end
    where(conditions.join(" OR "))
  end

  # needed for views in case we've got multiple assets on the same page
  # TODO: this is a view concern, move to helper, or better yet, deal w/it in .js
  def unique_id
    object_id.to_s
  end

  # make sure the title is there, and if not, the filename is used...
  def name
    return title.strip if title.present?

    name = audio_file.attached? ? audio_file.filename.base : nil
    name.presence || 'untitled'
  end

  def first_playlist
    Track.where(asset_id: id).first.playlists.first
  rescue StandardError
    nil
  end

  # Helper for rakismet
  def user_ip
    user.current_login_ip
  end

  # allows classes outside Asset to use the same format
  def self.formatted_time(time)
    if time
      min_and_sec = time.divmod(60)
      minutes = min_and_sec[0].to_i.to_s
      seconds = min_and_sec[1].to_i.to_s
      seconds = "0" + seconds if seconds.length == 1
      minutes + ':' + seconds
    else
      "?:??"
    end
  end

  def length
    self.class.formatted_time(self[:length])
  end

  def seconds
    self[:length] # a bit backwards, ain't it?
  end

  def published?
    !private?
  end

  def publish!
    update(private: false) && notify_followers if private?
  end

  # needed for spam detection
  def full_permalink
    "https://#{hostname}/#{user.login}/tracks/#{permalink}"
  end

  def notify_followers
    user.followers.includes(:settings).where('settings.email_new_tracks = ?', true).pluck(:id).each do |user_id|
      AssetNotificationJob.set(wait: 10.minutes).perform_later(asset_ids: id, user_id: user_id)
    end
  end

  def create_waveform
    WaveformExtractJob.perform_later(id)
  end

  def role
    if user.moderator?
      'admin'
    else
      'user'
    end
  end

  def download_location
    return nil unless audio_file.attached?

    Storage::Location.new(audio_file, signed: true)
  end

  def self.destroy_deleted_accounts_older_than_30_days
    Asset.destroyable.find_each do |asset|
      AssetCommand.new(asset).destroy_with_relations
    end
  end

  def self.filter_by(filter)
    case filter
    when "deleted"
      only_deleted.where(is_spam: false).order('deleted_at DESC')
    when "is_spam"
      with_deleted.where(is_spam: true).order('deleted_at DESC')
    when "not_spam"
      where(is_spam: false).recent
    else
      with_deleted.recent
    end
  end

  def update_user_assets_count
    user.increment!(:assets_count, touch: true)
  end
end

# == Schema Information
#
# Table name: assets
#
#  id               :integer          not null, primary key
#  album            :string(255)
#  artist           :string(255)
#  bitrate          :integer
#  comments_count   :integer          default(0)
#  credits          :text(4294967295)
#  deleted_at       :datetime
#  description      :text(4294967295)
#  description_html :text(4294967295)
#  favorites_count  :integer          default(0)
#  genre            :string(255)
#  hotness          :float(24)
#  id3_track_num    :integer          default(1)
#  is_spam          :boolean          default(FALSE)
#  length           :integer
#  listens_count    :integer          default(0)
#  listens_per_week :float(24)
#  lyrics           :text(4294967295)
#  mp3_content_type :string(255)
#  mp3_file_name    :string(255)
#  mp3_file_size    :integer
#  permalink        :string(255)
#  private          :boolean          default(FALSE), not null
#  samplerate       :integer
#  thumbnails_count :integer          default(0)
#  title            :string(255)
#  youtube_embed    :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer
#
# Indexes
#
#  index_assets_on_hotness                      (hotness)
#  index_assets_on_permalink                    (permalink)
#  index_assets_on_updated_at                   (updated_at)
#  index_assets_on_user_id                      (user_id)
#  index_assets_on_user_id_and_listens_per_day  (user_id,listens_per_week)
#

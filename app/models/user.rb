# frozen_string_literal: true

class User < ApplicationRecord
  include SoftDeletion
  include Rakismet::Model

  rakismet_attrs  author: proc { display_name },
                  author_email: proc { email },
                  user_ip: proc { current_login_ip },
                  content: proc { profile&.bio },
                  user_agent: proc { profile&.user_agent },
                  comment_type: 'signup'

  require_dependency 'user/findability'
  require_dependency 'user/settings'
  require_dependency 'user/statistics'

  include User::Findability
  include User::Settings
  include User::Statistics

  validates_length_of :display_name, within: 3..50, allow_blank: true

  validates :email,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "should look like an email address."
    },
    length: { maximum: 100 },
    uniqueness: {
      case_sensitive: false,
      if: :will_save_change_to_email?
    }

  validates :login,
    format: {
      with: /\A\w+\z/,
      message: "should use only letters and numbers."
    },
    length: { within: 3..100 },
    uniqueness: {
      case_sensitive: false,
      if: :will_save_change_to_login?
    }

  validates :password,
    confirmation: { if: :require_password? },
    length: {
      minimum: 8,
      if: :require_password?
    }

  validates :password_confirmation,
    length: {
      minimum: 8,
      if: :require_password?
    }

  store :settings

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
    c.disable_perishable_token_maintenance = true # we will handle tokens
  end

  scope :activated,     -> { where(perishable_token: nil).recent }
  scope :alpha,         -> { order('display_name ASC') }
  scope :geocoded,      -> { where(['users.lat != ""']).recent }
  scope :musicians,     -> { where(['assets_count > ?', 0]).order('assets_count DESC') }
  scope :random_order,  -> { order(Arel.sql('RAND()')) }
  scope :recent,        -> { order('users.id DESC') }
  scope :recently_seen, -> { order('last_request_at DESC') }
  scope :with_location, -> { where(['users.country != ""']).recently_seen }

  # The before destroy has to be declared *before* has_manys
  # This ensures User#efficiently_destroy_relations executes first
  before_create :make_first_user_admin
  before_destroy :destroy_with_relations
  before_save { |u| u.display_name = u.login if u.display_name.blank? }
  after_create :create_profile

  # Can create music
  has_one    :pic, as: :picable, dependent: :destroy
  has_one    :profile, dependent: :destroy
  has_many   :assets,
    -> { order('assets.id DESC') },
    dependent: :destroy

  has_many   :playlists, -> { order('playlists.position') },
    dependent: :destroy

  has_many   :comments, -> { order('comments.id DESC') },
    dependent: :destroy

  has_many   :tracks,
    dependent: :destroy

  # alonetone plus
  has_many :memberships
  has_many :groups, through: :membership

  # Can listen to music, and have that tracked
  has_many :listens, -> { order('listens.created_at DESC') }, foreign_key: 'listener_id'

  has_many :listened_to_tracks,
    -> { order('listens.created_at DESC') },
    through: :listens,
    source: :asset

  # Can have their music listened to
  has_many :track_plays,
    -> { order('listens.created_at DESC').includes(:asset) },
    foreign_key: 'track_owner_id',
    class_name: 'Listen'

  # And therefore have listeners
  has_many :listeners,
    -> { distinct },
    through: :track_plays

  has_many :followings, dependent: :destroy
  has_many :follows, dependent: :destroy, class_name: 'Following', foreign_key: 'follower_id'

  # people who are following this musician
  has_many :followers, through: :followings

  # musicians who this person follows
  has_many :followees, through: :follows, source: :user

  # old forum
  has_many :posts,  -> { order("#{Post.table_name}.created_at desc") }
  has_many :topics, -> { order("topics.created_at desc") }

  # will be removed along with /greenfield
  has_many :greenfield_posts, through: :assets

  # We have to define attachments last to make the Active Record callbacks
  # fire in the right order.
  has_one_attached :avatar_image

  # tokens and activation
  def clear_token!
    update_attribute(:perishable_token, nil)
  end

  def active?
    perishable_token.nil?
  end

  def activate!
    !active? ? clear_token! : false
  end

  def self.destroy_deleted_accounts_older_than_30_days
    User.destroyable.find_each do |u|
      u.destroy
    end
  end

  def self.with_same_ip_as(user)
    User.where(current_login_ip: user.current_login_ip).where('id != ?', user.id)
  end

  def self.find_by_login_or_email(login)
    User.find_by_login(login) || User.find_by_email(login)
  end

  def listened_to_today_ids
    listens.select('listens.asset_id').where(['listens.created_at > ?', 1.day.ago]).pluck(:asset_id)
  end

  def listened_to_ids
    listens.select('listens.asset_id').pluck(:asset_id).uniq
  end

  def top_tracks
    assets.order('listens_count DESC').limit(10)
  end

  def favorites
    playlists.favorites.first
  end

  def to_param
    login.to_s
  end

  def listened_more_than?(n)
    listens.count > n
  end

  def hasnt_been_here_in(hours)
    ast_login_at &&
      last_login_at < hours.ago.utc
  end

  def is_following?(user)
    follows.find_by_user_id(user)
  end

  def new_tracks_from_followees(limit)
    Asset.new_tracks_from_followees(self, limit)
  end

  def follows_user_ids
    follows.pluck(:user_id)
  end

  def has_followees?
    follows.count > 0
  end

  def add_or_remove_followee(followee_id)
    return if followee_id == id # following yourself would be a pointless affair!
    if is_following?(followee_id)
      is_following?(followee_id).destroy
    else
      follows.where(user_id: followee_id).first_or_create
    end
  end

  # convenince shortcut
  def ip
    current_login_ip
  end

  def similar_users_by_ip
    User.where('last_login_ip = ? or last_login_ip = ? or current_login_ip = ? or current_login_ip = ?',
      last_login_ip, current_login_ip, last_login_ip, current_login_ip).pluck(:id)
  end

  def toggle_favorite(asset)
    existing_track = tracks.favorites.where(asset_id: asset.id).first
    if existing_track
      existing_track.destroy && Asset.decrement_counter(:favorites_count, asset.id)
    else
      tracks.favorites.create(asset_id: asset.id)
      Asset.increment_counter(:favorites_count, asset.id, touch: true)
    end
  end

  def brand_new?
    created_at > 24.hours.ago
  end

  # Returns true when the user has a usable avatar.
  def avatar_image_present?
    avatar_image.attached?
  end

  # Generates a location to user's avatar with the requested variant. Returns nil when the user
  # does not have a usable avatar.
  def avatar_image_location(variant:)
    return unless avatar_image.attached?

    Storage::Location.new(
      ImageVariant.variant(avatar_image, variant: variant),
      signed: false
    )
  end

  def deleted?
    deleted_at != nil
  end

  def destroy_with_relations
    UserCommand.new(self).destroy_with_relations
  end

  def self.filter_by(filter)
    case filter
    when "deleted"
      only_deleted.where(is_spam: false).order('deleted_at DESC')
    when "is_spam"
      with_deleted.where(is_spam: true).order('deleted_at DESC')
    when "spam_musicians"
      musicians.with_deleted.where(is_spam: true).order('deleted_at DESC')
    when "not_spam"
      with_deleted.where(is_spam: false).recent
    when String
      with_deleted.where("email like '%#{filter}%' or login like '%#{filter}%'").recent
    else
      with_deleted.recent
    end
  end

  protected

  def make_first_user_admin
    self.admin = true if User.count == 0
  end
end

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  admin              :boolean          default(FALSE)
#  assets_count       :integer          default(0), not null
#  bandwidth_used     :integer          default(0)
#  comments_count     :integer          default(0)
#  crypted_password   :string(128)      default(""), not null
#  current_login_at   :datetime
#  current_login_ip   :string(255)
#  deleted_at         :datetime
#  display_name       :string(255)
#  email              :string(100)
#  followers_count    :integer          default(0)
#  greenfield_enabled :boolean          default(FALSE)
#  is_spam            :boolean          default(FALSE)
#  itunes             :string(255)
#  last_login_at      :datetime
#  last_login_ip      :string(255)
#  last_request_at    :datetime
#  listens_count      :integer          default(0)
#  login              :string(40)
#  login_count        :integer          default(0), not null
#  moderator          :boolean          default(FALSE)
#  perishable_token   :string(255)
#  persistence_token  :string(255)
#  playlists_count    :integer          default(0), not null
#  posts_count        :integer          default(0)
#  salt               :string(128)      default(""), not null
#  settings           :text(4294967295)
#  use_old_theme      :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_users_on_updated_at  (updated_at)
#

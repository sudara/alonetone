class User < ActiveRecord::Base
  concerned_with :validation, :findability, :settings, :statistics

  store :settings

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
    c.disable_perishable_token_maintenance = true # we will handle tokens
  end

  scope :recent,        -> { order('users.id DESC')                                   }
  scope :recently_seen, -> { order('last_request_at DESC')                            }
  scope :musicians,     -> { where(['assets_count > ?', 0]).order('assets_count DESC') }
  scope :activated,     -> { where(perishable_token: nil).recent }
  scope :with_location, -> { where(['users.country != ""']).recently_seen             }
  scope :geocoded,      -> { where(['users.lat != ""']).recent                        }
  scope :alpha,         -> { order('display_name ASC')                                }

  # The before destroy has to be declared *before* has_manys
  # This ensures User#efficiently_destroy_relations executes first
  before_create :make_first_user_admin
  before_destroy :efficiently_destroy_relations
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

  has_many   :tracks

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
    Asset.new_tracks_from_followees(self, page: 1, per_page: limit)
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

  protected

  def efficiently_destroy_relations
    Listen.where(track_owner_id: id).delete_all
    Listen.where(listener_id: id).delete_all
    Topic.where(user_id: id).where('posts_count < 2').destroy_all # get rid of all orphaned topics

    Playlist.joins(:assets).where(assets: { user_id: id })
            .update_all(['tracks_count = tracks_count - 1, playlists.updated_at = ?', Time.now])
    Track.joins(:asset).where(assets: { user_id: id }).delete_all

    Comment.joins("INNER JOIN assets ON commentable_type = 'Asset' AND commentable_id = assets.id")
           .joins('INNER JOIN users ON assets.user_id = users.id').where('users.id = ?', id).delete_all

    assets.destroy_all

    %w[tracks playlists posts comments].each do |user_relation|
      send(user_relation).delete_all
    end
    true
  end

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
#  display_name       :string(255)
#  email              :string(100)
#  followers_count    :integer          default(0)
#  greenfield_enabled :boolean          default(FALSE)
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
#  settings           :text(16777215)
#  use_old_theme      :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_users_on_updated_at  (updated_at)
#

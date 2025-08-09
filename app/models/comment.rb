class Comment < ActiveRecord::Base
  include SoftDeletion

  scope :recent,             -> { order('comments.id DESC') }
  scope :only_public,        -> { recent.where(is_spam: false).where(private: false) }
  scope :by_member,          -> { recent.where('commenter_id IS NOT NULL') }
  scope :include_private,    -> { recent.where(is_spam: false) }
  scope :public_or_private,  ->(has_access) { has_access ? include_private : only_public }
  scope :spam,               -> { recent.where(is_spam: true) }
  scope :on_track,           -> { where(commentable_type: 'Asset') }
  scope :last_5_private,     -> { on_track.with_preloads.include_private.limit(5) }
  scope :last_5_public,      -> { on_track.with_preloads.only_public.limit(5) }
  scope :made_between,       ->(start, finish) { where('comments.created_at BETWEEN ? AND ?', start, finish) }
  scope :to_other_members,   -> { joins(:user).where("users.current_login_ip != remote_ip").where("commenter_id != user_id") }

  def self.with_preloads
    includes(
      commenter: { avatar_image_attachment: :blob },
      commentable: { user: { avatar_image_attachment: :blob } }
    )
  end

  has_many :replies, as: :commentable, class_name: 'Comment'

  # optional user who made the comment
  belongs_to :commenter,
    -> { with_deleted },
    class_name: 'User',
    optional: true

  # optional user who is *recieving* the comment
  # this helps simplify a user lookup of all comments across tracks/playlists/whatever
  belongs_to :user, optional: true

  belongs_to :commentable, polymorphic: true, touch: true
  validates_length_of :body, within: 1..2000

  before_create :disallow_dupes, :set_user
  after_create :increment_counters

  before_save :truncate_user_agent

  include Rakismet::Model
  rakismet_attrs  author: proc { author_name },
                  author_email: proc { commenter&.email },
                  content: proc { body },
                  user_role: proc { role },
                  permalink: proc { commentable.try(:full_permalink) }
  # Poor man's anti-spam helper
  def duplicate?
    # Allow single emojis to be posted multiple times
    return false if body.length == 1

    Comment.where(remote_ip: remote_ip, body: body).where('created_at > ?', 1.hour.ago).first.present?
  end

  def disallow_dupes
    throw(:abort) if duplicate?
  end

  def set_user
    self.user = commentable&.user
  end

  # Rakismet is failing to get ip via middleware
  def user_ip
    remote_ip
  end

  def role
    if commenter&.moderator?
      'admin'
    elsif commenter.present?
      'user'
    else
      'guest'
    end
  end

  def author_name
    if commenter
      commenter.login
    else
      'guest'
    end
  end

  def user_logged_in
    !!commenter_id
  end

  def increment_counters
    return if is_spam?

    if commentable.is_a? Asset
      User.increment_counter(:comments_count, commentable.user, touch: true)
      Asset.increment_counter(:comments_count, commentable, touch: true)
    end
  end

  def is_deliverable?
    !is_spam? && (commentable.class == Asset) &&
      user.email_comments? && (user != commenter)
  end

  def truncate_user_agent
    self.user_agent = user_agent.try(:slice, 0, 255)
  end

  def self.over_rate_limit_for_ip?(remote_ip)
    Comment.where(remote_ip: remote_ip).where('created_at > ?', 24.hours.ago).count >= 5
  end

  def abuse_from_guest?
    !commenter.present? && Comment.over_rate_limit_for_ip?(remote_ip)
  end
end

# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text(16777215)
#  body_html        :text(16777215)
#  commentable_type :string(255)
#  deleted_at       :datetime
#  is_spam          :boolean          default(FALSE)
#  private          :boolean          default(FALSE)
#  referrer         :string(255)
#  remote_ip        :string(255)
#  user_agent       :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  commentable_id   :integer
#  commenter_id     :integer
#  user_id          :integer
#
# Indexes
#
#  by_user_id_type_spam_private                                (user_id,commentable_type,is_spam,private)
#  index_comments_on_commentable_id                            (commentable_id)
#  index_comments_on_commentable_type_and_is_spam_and_private  (commentable_type,is_spam,private)
#  index_comments_on_commenter_id                              (commenter_id)
#

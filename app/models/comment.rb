class Comment < ActiveRecord::Base
  scope :recent,             -> { order('id DESC') }
  scope :only_public,        -> { recent.where(is_spam: false).where(private: false) }
  scope :by_member,          -> { recent.where('commenter_id IS NOT NULL') }
  scope :include_private,    -> { recent.where(is_spam: false) }
  scope :public_or_private,  ->(has_access) { has_access ? include_private : only_public }
  scope :spam,               -> { recent.where(is_spam: true) }
  scope :on_track,           -> { where(commentable_type: 'Asset') }
  scope :last_5_private,     -> { on_track.include_private.limit(5).preload(commenter: :pic, commentable: { user: :pic }) }
  scope :last_5_public,      -> { on_track.only_public.limit(5).preload(commenter: :pic, commentable: { user: :pic }) }
  scope :made_between,       ->(start, finish) { where('comments.created_at BETWEEN ? AND ?', start, finish) }
  scope :to_other_members,   -> { where("commenter_id != user_id") }

  has_many :replies, as: :commentable, class_name: 'Comment'

  # optional user who made the comment
  belongs_to :commenter, class_name: 'User'

  # optional user who is *recieving* the comment
  # this helps simplify a user lookup of all comments across tracks/playlists/whatever
  belongs_to :user

  belongs_to :commentable, polymorphic: true, touch: true
  validates_length_of :body, within: 1..2000
  validates :commentable_id, presence: true

  before_create :disallow_dupes, :set_user
  after_create :increment_counters

  before_save :truncate_user_agent

  include Rakismet::Model
  rakismet_attrs  author: proc { author_name },
                  author_email: proc { commenter&.email },
                  content: proc { body },
                  user_role: proc { role },
                  permalink: proc { commentable.try(:full_permalink) }

  def duplicate?
    Comment.where(remote_ip: remote_ip, body: body).first.present?
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
    if commentable.is_a? Asset
      User.increment_counter(:comments_count, commentable.user, touch: true)
      Asset.increment_counter(:comments_count, commentable, touch: true)
    end
  end

  def is_deliverable?
    !is_spam? && (commentable.class == Asset) &&
      user.wants_email? && (user != commenter)
  end

  def truncate_user_agent
    self.user_agent = user_agent.try(:slice, 0, 255)
  end
end

# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text(65535)
#  body_html        :text(65535)
#  commentable_type :string(255)
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

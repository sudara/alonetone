# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  topic_id   :integer
#  body       :text(65535)
#  created_at :datetime
#  updated_at :datetime
#  forum_id   :integer
#  body_html  :text(65535)
#  is_spam    :boolean          default(FALSE)
#  spaminess  :float(24)
#  signature  :string(255)
#

class Post < ActiveRecord::Base
  @@per_page = 10
  cattr_accessor :per_page

  scope :recent, ->   { order("posts.created_at asc") }
  scope :not_spam, -> { where(is_spam: false) }
  scope :spam, ->  { where(is_spam: true) }

  # author of post
  belongs_to :user, counter_cache: true
  belongs_to :topic, counter_cache: true

  # topic's forum (set by callback)
  belongs_to :forum, counter_cache: true

  validates_presence_of :topic, :forum, :body
  validate :topic_is_not_locked

  before_create :set_spam_status
  after_create  :update_cached_fields
  after_destroy :update_cached_fields

  include Rakismet::Model
  rakismet_attrs  author: proc { author_name },
                  author_email: proc { user.email },
                  content: proc { body },
                  permalink: proc { topic.try(:full_permalink) }

  def set_spam_status
    self.is_spam = spam? # makes API request
    true
  end

  def author_name
    if user.present?
      user.login
    else
      "[deleted]"
    end
  end

  def self.search(params)
    where = if params[:forum_q].present?
              not_spam.where("LOWER(posts.body) LIKE ?", "%#{params[:forum_q]}%")
            elsif params[:spam].present?
              where(is_spam: true)
            else
              not_spam
            end
    where.includes(topic: :forum).order("posts.created_at DESC")
  end

  def editable_by?(user)
    user && (user.id == user_id || user.moderator? || user.admin?)
  end

  protected

  def update_cached_fields
    topic.update_cached_post_fields(self)
  end

  def topic_is_not_locked
    errors.add_to_base("Topic is locked") if topic&.locked?
  end
end

# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  body       :text(65535)
#  body_html  :text(65535)
#  is_spam    :boolean          default(FALSE)
#  signature  :string(255)
#  spaminess  :float(24)
#  created_at :datetime
#  updated_at :datetime
#  forum_id   :integer
#  topic_id   :integer
#  user_id    :integer
#
# Indexes
#
#  index_posts_on_is_spam  (is_spam)
#

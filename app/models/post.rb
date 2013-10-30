class Post < ActiveRecord::Base

  @@per_page = 10
  cattr_accessor :per_page
  
  scope :recent, -> { order("posts.created_at desc") }
  
  # author of post
  belongs_to :user, :counter_cache => true
  belongs_to :topic, :counter_cache => true
  
  # topic's forum (set by callback)
  belongs_to :forum, :counter_cache => true
  
  validates_presence_of :user_id, :topic_id, :forum_id, :body
  validate :topic_is_not_locked

  after_create  :update_cached_fields
  after_destroy :update_cached_fields

  def author_name
    user.login
  end

  def user_logged_in
    true
  end

  attr_accessible :body

  def self.search(query, options = {})
    options[:conditions] ||= ["LOWER(posts.body) LIKE ?", "%#{query}%"] unless query.blank?
    options[:select]     ||= "posts.*, topics.title as topic_title, #{Forum.table_name}.name as forum_name"
    options[:joins]      ||= "inner join topics on posts.topic_id = topics.id inner join #{Forum.table_name} on topics.forum_id = #{Forum.table_name}.id"
    options[:order]      ||= "posts.created_at DESC"
    options[:count]      ||= {:select => "posts.id"}
    paginate options
  end

  def editable_by?(user)
    user && (user.id == user_id || user.moderator? || user.admin?)
  end
  
protected
  def update_cached_fields
    topic.update_cached_post_fields(self)
  end
  
  def topic_is_not_locked
    errors.add_to_base("Topic is locked") if topic && topic.locked?
  end
end

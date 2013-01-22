# -*- encoding : utf-8 -*-
class Post < ActiveRecord::Base
  
  

  @@per_page = 10
  cattr_accessor :per_page
  # author of post
  belongs_to :user, :counter_cache => true
  
  belongs_to :topic, :counter_cache => true
  
  # topic's forum (set by callback)
  belongs_to :forum, :counter_cache => true
  
  validates_presence_of :user_id, :topic_id, :forum_id, :body
  validate :topic_is_not_locked

  after_create  :update_cached_fields
  after_destroy :update_cached_fields

  ##acts_as_defensio_article_comment :fields => { :content => :body, 
  #                                      :article => :topic, 
  #                                      :author => :author_name }

  def author_name
    user.login
  end

  def user_logged_in
    true
  end

  attr_accessible :body

  def self.search(query, options = {})
    options[:conditions] ||= ["LOWER(#{Post.table_name}.body) LIKE ?", "%#{query}%"] unless query.blank?
    options[:select]     ||= "#{Post.table_name}.*, #{Topic.table_name}.title as topic_title, #{Forum.table_name}.name as forum_name"
    options[:joins]      ||= "inner join #{Topic.table_name} on #{Post.table_name}.topic_id = #{Topic.table_name}.id inner join #{Forum.table_name} on #{Topic.table_name}.forum_id = #{Forum.table_name}.id"
    options[:order]      ||= "#{Post.table_name}.created_at DESC"
    options[:count]      ||= {:select => "#{Post.table_name}.id"}
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

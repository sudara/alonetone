# -*- encoding : utf-8 -*-
class Forum < ActiveRecord::Base
  
  scope :ordered, -> { order('position ASC') }
  
  acts_as_list

  has_permalink :name

  validates_presence_of :name
      
  attr_readonly :posts_count, :topics_count

  has_many :topics,
    -> { order("#{Topic.table_name}.sticky desc, #{Topic.table_name}.last_updated_at desc")},
    :dependent  => :delete_all

  # used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_topics, 
    -> { order("#{Topic.table_name}.last_updated_at DESC").conditions("users.state == ?", "active").includes(:user)},
    :class_name => 'Topic'
    
  has_one  :recent_topic,  
    -> { order("#{Topic.table_name}.last_updated_at DESC") },
    :class_name => 'Topic'

  has_many :posts, 
    -> { order("#{Post.table_name}.created_at DESC") },
    :dependent  => :delete_all
    
  has_one :recent_post, 
    -> { order("#{Post.table_name}.created_at DESC") },
    :class_name => 'Post'
  
  def to_param
    permalink
  end
end

class Forum < ActiveRecord::Base
  
  scope :ordered, -> { order('position ASC') }
  
  acts_as_list
  has_permalink :name

  validates_presence_of :name   
  attr_readonly :posts_count, :topics_count
  
  has_many :topics, :dependent  => :delete_all
  has_many :posts, :dependent  => :delete_all
    
  def recent_post
    posts.order('created_at DESC').first
  end  
    
  def recent_topic
    recent_topics.first
  end    
  
  def recent_topics
    topics.recent.includes(:user)
  end
  
  def to_param
    permalink
  end
end

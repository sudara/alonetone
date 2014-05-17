class Forum < ActiveRecord::Base
  
  scope :ordered, -> { order('position ASC') }
  scope :with_topics, -> { preload(:recent_post).preload(:recent_topic) }
  
  acts_as_list
  has_permalink :name

  validates_presence_of :name   
  attr_readonly :posts_count, :topics_count
      
  has_many :topics, :dependent  => :delete_all
  has_many :posts, :dependent  => :delete_all
  
  has_one  :recent_topic,
    -> { not_spam.recent },
    :class_name => "Topic"
    
  has_one :recent_post,
  -> { not_spam.order('created_at DESC') },
  :class_name => "Post"
    
  
  def to_param
    permalink
  end
end

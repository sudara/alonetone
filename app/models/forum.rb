class Forum < ActiveRecord::Base
  named_scope :ordered, {:order => :position}
  
  formats_attributes :description
  
  acts_as_list

  validates_presence_of :name
    
  has_permalink :name
  before_save :create_unique_permalink
  
  attr_readonly :posts_count, :topics_count

  has_many :topics, :order => "#{Topic.table_name}.sticky desc, #{Topic.table_name}.last_updated_at desc", :dependent => :delete_all

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_topics, :class_name => 'Topic', :include => [:user],
    :order => "#{Topic.table_name}.last_updated_at DESC",
    :conditions => ["users.state == ?", "active"]
  has_one  :recent_topic,  :class_name => 'Topic', :order => "#{Topic.table_name}.last_updated_at DESC"

  has_many :posts,       :order => "#{Post.table_name}.created_at DESC", :dependent => :delete_all
  has_one  :recent_post, :order => "#{Post.table_name}.created_at DESC", :class_name => 'Post'
  
  def to_param
    permalink
  end
end
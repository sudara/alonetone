class Topic < ActiveRecord::Base

  before_validation :set_default_attributes, :on => :create
  before_update  :check_for_moved_forum
  after_update   :set_post_forum_id
  before_destroy :count_user_posts_for_counter_cache
  after_destroy  :update_cached_forum_and_user_counts

  scope :with_user, -> { preload(:last_user, :user) }
  scope :recent, -> { order('topics.created_at DESC') }
  scope :not_spam, -> { where(:spam => false).with_user }
  scope :spam,    ->  { where(:spam => true).with_user }
  scope :sticky_and_recent, -> { order("topics.sticky desc, topics.last_updated_at desc") }
  scope :for_footer, -> { recent.not_spam.includes(:recent_post => :user).includes(:forum).limit(3) }
  # creator of forum topic
  belongs_to :user
  
  # creator of recent post
  belongs_to :last_user, :class_name => "User"
  belongs_to :forum, :counter_cache => true

  has_many :posts, :dependent => :delete_all
   
  has_one  :recent_post,
    -> { not_spam.order('posts.created_at DESC') },
    :class_name => "Post"
  
  has_many :voices,
    -> { uniq },
    :through => :posts, :source => :user
  
  validates_presence_of :user_id, :forum_id, :title
  
  validates_presence_of :body, :on => :create

  attr_accessor :body
  attr_accessible :title, :body, :sticky, :locked
  attr_readonly :posts_count, :hits
  
  has_permalink :title, true
                               
  # hacks for defensio
  def article
    self
  end
  
  def author_name 
    user.login
  end
  
  def editable_by?(user)
    user && (user.id == user_id || user.moderator? || user.admin?)
  end
  
  def full_permalink
    "http://#{Alonetone.url}/forums/#{permalink}"
  end
  
  def sticky?
    sticky == 1
  end
  
  def hit!
    self.class.increment_counter :hits, id
  end

  def paged?
    posts_count > Post.per_page
  end
  
  def last_page
    [(posts_count.to_f / Post.per_page.to_f).ceil.to_i, 1].max
  end

  def update_cached_post_fields(post)
    # these fields are not accessible to mass assignment
    if remaining_post = post.frozen? ? recent_post : post
      update_columns(:last_updated_at => remaining_post.created_at, 
        :last_user_id => remaining_post.user_id,
        :last_post_id => remaining_post.id)
      Topic.reset_counters id, :posts
    else
      self.destroy
    end
  end
  
  def to_param
    permalink
  end

  def self.replied_to_by(user)
    user.posts.not_spam.select('distinct posts.topic_id, topics.*').order('topics.last_updated_at DESC').limit(5).joins(:topic)
  end

  def self.popular
    Post.group(:topic).not_spam.where(['posts.created_at > ?',10.days.ago]).limit(3).order('count_all DESC').count
  end

  def self.replyless
    Topic.not_spam.limit(3).order('created_at DESC').where(:posts_count => 1)
  end

protected
  
  def set_default_attributes
    self.sticky          ||= 0
    self.last_updated_at ||= Time.now.utc
  end

  def check_for_moved_forum
    old = Topic.find(id)
    @old_forum_id = old.forum_id if old.forum_id != forum_id
    true
  end

  def set_post_forum_id
    return unless @old_forum_id
    posts.update_all :forum_id => forum_id
    Forum.decrement_counter(:topics_count, @old_forum_id)
    Forum.increment_counter(:topics_count, forum_id)
  end
  
  def count_user_posts_for_counter_cache
    @user_posts = posts.group_by { |p| p.user_id }
  end
  
  def update_cached_forum_and_user_counts
    Forum.where(:id => forum_id).update_all "posts_count = posts_count - #{posts_count}"
    @user_posts.each do |user_id, posts|
      User.where(:id => user_id).update_all "posts_count = posts_count - #{posts.size}"
    end
  end
end

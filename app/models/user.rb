class User < ActiveRecord::Base
  concerned_with :validation, :findability, :profile, :statistics, :posting
    
  named_scope :musicians, {
    :conditions => ['assets_count > ?',0], 
    :order      => 'assets_count DESC', 
  }
  
  named_scope :activated, {
    :conditions => {:activation_code => nil}, 
    :order      => 'users.id DESC', 
  }
  
  named_scope :recently_seen, {
    :order    => 'last_seen_at DESC', 
  }
  
  named_scope :with_location, {
    :conditions => ['users.country != ""'], 
    :order      => 'last_seen_at DESC', 
  }
  
  named_scope :geocoded, {
    :conditions => ['users.lat != ""'], 
    :order      => 'users.id DESC', 
  }
  
  named_scope :on_twitter, { 
    :conditions => ['users.twitter != ?', ''], 
    :order => 'users.last_seen_at DESC' }
  
  named_scope :alpha, { :order => 'display_name' }
  
  # Can create music
  has_one    :pic,           :as => :picable
  has_many   :assets,        :dependent => :destroy, :order => 'assets.id DESC'
  has_many   :playlists,     :dependent => :destroy, :order => 'playlists.position', :include => :pic
  has_many   :comments,      :dependent => :destroy, :order => 'id DESC', :include => [:commenter => :pic]
  has_many   :user_reports,  :dependent => :destroy, :order => 'id DESC'
  has_many   :tracks
  
  acts_as_mappable
  before_validation :geocode_address

  reportable :weekly, :aggregation => :count, :grouping => :week

  # alonetone plus
  has_many :source_files
  
  has_many :memberships
  has_many :groups, :through => :membership
  
  
  # Can listen to music, and have that tracked
  has_many :listens, 
    :foreign_key  => 'listener_id', 
    :order        => 'listens.created_at DESC',
    :include      => :asset
    
  # Can have their music listened to
  has_many :track_plays, 
    :foreign_key  => 'track_owner_id', 
    :class_name   => 'Listen', 
    :order        => 'listens.created_at DESC',
    :include      => :asset
  
  # And therefore have listeners
  has_many :listeners, 
    :through  => :track_plays, 
    :uniq     => true
  
  # top tracks
  has_many :top_tracks, 
    :class_name => 'Asset', 
    :limit      => 10, 
    :order      => 'listens_count DESC'
  
  
  has_many :followings, :dependent => :destroy
  has_many :follows, :dependent => :destroy, :class_name => 'Following', :foreign_key => 'follower_id'    
  
  # people who are following this musician
  has_many :followers, :through => :followings

  # musicians who this person follows
  has_many :followees, :through => :follows, :source => :user

  # The following attributes can be changed via mass assignment 
  attr_accessible :login, :email, :password, :password_confirmation, :website, :myspace,
                  :bio, :display_name, :itunes, :settings, :city, :country, :twitter
  
  before_create :make_first_user_admin, :make_activation_code
  
  before_destroy :efficiently_destroy_relations
  
  def listened_to_today_ids
    listens.find(:all, 
      :select     =>  'listens.asset_id', 
      :conditions => ['listens.created_at > ?', 1.day.ago]
    ).collect(&:asset_id)
  end
  
  def listened_to_ids
    listens.find(:all, :select => 'listens.asset_id').collect(&:asset_id).uniq
  end
    
  def to_param
    "#{login}"
  end
    
  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :email << :token << :token_expires_at << :crypted_password << 
                        :identity_url << :fb_user_id << :activation_code << :admin << 
                        :salt << :moderator << :ip << :browser << :settings << :plus_enabled
    super
  end
  
  def listened_more_than?(n)
    listens.count > n
  end
  
  def moderator?
    (self[:moderator] == true)
  end
  
  def hasnt_been_here_in(hours)
    last_seen_at && last_session_at &&
    last_seen_at < hours.ago.utc
  end
  
  def is_following?(user)
    follows.find_by_user_id(user)
  end
  
  def new_tracks_from_followees(limit)
    Asset.new_tracks_from_followees(self,{:page => 1, :per_page => limit})
  end
  
  def follows_user_ids
    follows.collect{|f| f.user_id}
  end
  
  def has_followees?
    follows.count > 0
  end
    
  def add_or_remove_followee(followee_id)
    return if followee_id == id # following yourself would be a pointless affair!
    if is_following?(followee_id)
      is_following?(followee_id).destroy 
    else
      follows.find_or_create_by_user_id(followee_id)
    end
  end
  
  def type
    self.class.name
  end  
  
  def touch
    updated_at_will_change!
    save
  end

  protected

  def efficiently_destroy_relations
    tracks.delete_all
    playlists.delete_all
    Listen.delete_all(['track_owner_id = ?',id])
    Listen.delete_all(['listener_id = ?',id])
    posts.delete_all
    topics.delete_all
    comments.delete_all
    assets.delete_all
  end
  
  def make_first_user_admin
    self.admin = true if User.count == 0
  end
end

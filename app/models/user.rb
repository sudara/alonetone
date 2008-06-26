class User < ActiveRecord::Base
  concerned_with :validation, :findability, :profile, :statistics, :posting
  
  named_scope :musicians, {:conditions => ['assets_count > ?',0], :order => 'assets_count DESC', :include => :pic}
  named_scope :activated, {:conditions => {:activation_code => nil}, :order => 'created_at DESC', :include => :pic}
  named_scope :recently_seen, {:order => 'last_seen_at DESC', :include => :pic}  
  named_scope :with_location, {:conditions => ['users.country != ""'], :order => 'last_seen_at DESC', :include => :pic}
  named_scope :geocoded, {:conditions => ['users.lat != ""'], :order => 'created_at DESC', :include => :pic}
  named_scope :alpha, {:order => 'login'}
  
  # Can create music
  has_many   :assets,        :dependent => :destroy, :order => 'created_at DESC'
  has_many   :playlists,     :dependent => :destroy, :order => 'playlists.position'
  has_one    :pic,           :as => :picable
  has_many   :comments,      :dependent => :destroy, :order => 'created_at DESC'
  has_many   :user_reports,  :dependent => :destroy, :order => 'created_at DESC'
  
  belongs_to :facebook_account
  has_many :tracks
  
  acts_as_mappable
  before_validation :geocode_address
  
  has_many :source_files
  
  # Can listen to music, and have that tracked
  has_many :listens, :foreign_key => 'listener_id', :include => :asset, :order => 'listens.created_at DESC'
    
  # Can have their music listened to
  has_many :track_plays, :foreign_key => 'track_owner_id', :class_name => 'Listen', :include => [:asset], :order => 'listens.created_at DESC'
  
  # And therefore have listeners
  has_many :listeners, :through => :track_plays, :uniq => true
  
  # top tracks
  has_many :top_tracks, :class_name => 'Asset', :limit => 10, :order => 'listens_count DESC'

  # The following attributes can be changed via mass assignment 
  attr_accessible :login, :email, :password, :password_confirmation, :website, :myspace,
                  :bio, :display_name, :itunes, :settings, :city, :country
  
  before_create :make_first_user_admin, :make_activation_code
  
  def listened_to_today_ids
    self.listens.find(:all, :select => 'listens.asset_id', :conditions => ['listens.created_at > ?', 1.day.ago]).collect(&:asset_id)
  end
  
  def listened_to_ids
    self.listens.find(:all, :select => 'listens.asset_id').collect{|l| l.asset_id}.uniq
  end
    
  def to_param
    "#{self.login}"
  end
  
  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :email << :token << :token_expires_at << :crypted_password << :identity_url << :fb_user_id << :activation_code << :admin << :salt
    super
  end
  
  def moderator?
    (self[:moderator] == true)
  end
  
  protected
  
  def make_first_user_admin
    self.admin = true if User.count == 0
  end
end

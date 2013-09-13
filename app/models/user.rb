class User < ActiveRecord::Base
  concerned_with :validation, :findability, :profile, :statistics, :posting
    
  acts_as_authentic do |c|
    c.transition_from_restful_authentication = true
    c.login_field = :login
    c.disable_perishable_token_maintenance = true # we will handle tokens
  end

  scope :recent,        -> { order('users.id DESC')                                   }
  scope :recently_seen, -> { order('last_login_at DESC')                              }
  scope :musicians,     -> { where(['assets_count > ?',0]).order('assets_count DESC') }
  scope :activated,     -> { where(:perishable_token => nil).recent                   }
  scope :with_location, -> { where(['users.country != ""']).recently_seen             }
  scope :geocoded,      -> { where(['users.lat != ""']).recent                        }
  scope :on_twitter,    -> { where(['users.twitter != ?', '']).recently_seen          }
  scope :alpha,         -> { order('display_name ASC')                                }
  
  # Can create music
  has_one    :pic,           :as => :picable
  has_many   :assets, 
    -> { order('assets.id DESC')},
    :dependent => :destroy
    
  has_many   :playlists,     
    -> { order('playlists.position')},
    :dependent => :destroy
  
  has_many   :comments,
    -> {order('comments.id DESC').includes([:commenter => :pic])},
    :dependent => :destroy
  
  has_many   :tracks
  
  reportable :weekly, :aggregation => :count, :grouping => :week

  # alonetone plus
  has_many :source_files
  has_many :memberships
  has_many :groups, :through => :membership
  
  
  # Can listen to music, and have that tracked
  has_many :listens, 
    :foreign_key  => 'listener_id'
    
  has_many :listened_to_tracks, 
    -> { order('listens.created_at') },
    :through => :listens, 
    :source => :asset    
    
  # Can have their music listened to
  has_many :track_plays, 
    -> { order('listens.created_at DESC').includes(:asset)},
    :foreign_key  => 'track_owner_id', 
    :class_name   => 'Listen'
  
  # And therefore have listeners
  has_many :listeners, 
    -> { uniq },
    :through  => :track_plays
  
  # top tracks
  has_many :top_tracks, 
    -> { order('listens_count DESC').limit(10)},
    :class_name => 'Asset'
  
  
  has_many :followings, :dependent => :destroy
  has_many :follows, :dependent => :destroy, :class_name => 'Following', :foreign_key => 'follower_id'    
  
  # people who are following this musician
  has_many :followers, :through => :followings

  # musicians who this person follows
  has_many :followees, :through => :follows, :source => :user

  # The following attributes can be changed via mass assignment 
  attr_accessible :login, :email, :password, :password_confirmation, :website, :myspace,
                  :bio, :display_name, :itunes, :settings, :city, :country, :twitter
  
  before_create :make_first_user_admin
  
  before_destroy :efficiently_destroy_relations
  
  def listened_to_today_ids
    listens.select('listens.asset_id').where(['listens.created_at > ?', 1.day.ago]).collect(&:asset_id)
  end
  
  def listened_to_ids
    listens.select('listens.asset_id').uniq.collect(&:asset_id)
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
    follows.select(:user_id).collect(&:user_id)
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
  
  # convenince shortcut 
  def ip
    last_login_ip
  end

  def clear_token!
    self.update_attribute(:perishable_token,nil)
  end
  
  
  def active?
    perishable_token == nil
  end

  def activate!
    clear_token!
  end

  def deliver_activation_instructions!
    reset_perishable_token!
    UserNotification.signup(self).deliver
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

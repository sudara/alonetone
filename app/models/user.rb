require 'digest/sha1'
class User < ActiveRecord::Base
  
  # has a bunch of prefs
  serialize :settings
  
  named_scope :musicians, {:conditions => ['assets_count > ?',0], :order => 'assets_count DESC', :include => :pic}
  named_scope :activated, {:conditions => {:activation_code => nil}, :order => 'created_at DESC', :include => :pic}
  named_scope :recently_seen, {:order => 'last_seen_at DESC', :include => :pic}
  
  # Can create music
  has_many   :assets,        :dependent => :destroy, :order => 'created_at DESC'
  has_many   :playlists,     :dependent => :destroy, :order => 'playlists.created_at DESC'
  has_one    :pic,           :as => :picable
  has_many   :comments,      :dependent => :destroy, :order => 'created_at DESC'
  has_many   :user_reports,  :dependent => :destroy, :order => 'created_at DESC'
  
  has_many :tracks
  
  # Can listen to music, and have that tracked
  has_many :listens, :foreign_key => 'listener_id', :include => :asset, :order => 'listens.created_at DESC'
    
  # Can have their music listened to
  has_many :track_plays, :foreign_key => 'track_owner_id', :class_name => 'Listen', :include => :asset, :order => 'listens.created_at DESC'
  
  # And therefore have listeners
  has_many :listeners, :through => :track_plays, :uniq => true
  
  # top tracks
  has_many :top_tracks, :class_name => 'Asset', :limit => 10, :order => 'listens_count DESC'

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  # These attributes can be changed via mass assignment 
  attr_accessible :login, :email, :password, :password_confirmation, :website, :myspace,
                  :bio, :display_name, :itunes, :settings, :city, :country
  
  # Validations
  validates_presence_of     :email
  validates_format_of       :email, :with => Format::EMAIL
  validates_presence_of     :password,                        :if => :password_required?
  validates_presence_of     :password_confirmation,           :if => :password_required?
  validates_length_of       :password, :within => 5..40,      :if => :password_required?
  validates_confirmation_of :password,                        :if => :password_required?
  validates_length_of       :email,    :within => 3..40       
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_uniqueness_of   :login  
  validates_format_of       :login, :with => Format::STRING, :message => ' must be lowercase and only made from numbers and letters'
  validates_length_of       :login, :within => 3..40
  validates_length_of       :display_name, :within => 3..50, :allow_blank => true
  validates_length_of       :bio, :within => 0..200, :message => "can't be so long, sorry!", :on => :update
  
  validates_format_of       :identity_url, :with => /^https?:\/\//i, :allow_nil => true
  validates_format_of       :itunes, :with => /^phobos.apple.com\/WebObjects\/MZStore.woa\/wa\/viewPodcast\?id=/i, :allow_blank => true, :message => 'link must be a link to the itunes store'
  
  # Methods related to validation
  before_save { |u| u.display_name = u.login if u.display_name.blank? }
  before_validation { |u| u.identity_url = nil if u.identity_url.blank? }
  before_save :encrypt_password
  before_create :make_first_user_admin, :make_activation_code
    
  def self.currently_online
     User.find(:all, :conditions => ["last_seen_at > ?", Time.now-5.hours])
  end
  
  # Generates magic %LIKE% sql statements for all columns
  def self.conditions_by_like(value, *columns) 
    columns = self.content_columns if columns.size==0 
    columns = columns[0] if columns[0].kind_of?(Array) 
    conditions = columns.map {|c| 
    c = c.name if c.kind_of? ActiveRecord::ConnectionAdapters::Column 
    "#{c} LIKE " + ActiveRecord::Base.connection.quote("%#{value}%") 
    }.join(" OR ") 
  end
 
  def to_param
    "#{self.login}"
  end
  
  def has_public_playlists?
    playlists_count > 0 && playlists.detect{|p| p.has_tracks?}
  end
  
  def has_tracks?
    self.assets_count > 0 
  end
  
  def favorites
    self.playlists.favorites.first
  end
  
  def has_pic?
    pic && !pic.new_record?
  end

  # graphing

  def track_plays_graph
    Gchart.line(:size => '420x150',:title => 'listens', :data => track_play_history, :axis_with_labels => 'r,x', :axis_labels => ["0|#{(track_play_history.max.to_f/2).round}|#{track_play_history.max}","30 days ago|15 days ago|Today"], :line_colors =>'cc3300', :background => '313327', :custom => 'chm=B,3d4030,0,0,0&chls=3,1,0&chg=25,50,1,0') 
  end
  
  def track_play_history
    track_plays.count(:all, :conditions => ['listens.created_at > ?',30.days.ago.at_midnight], :group => 'DATE(listens.created_at)').collect{|tp| tp[1]}
  end
  
  def site
    "alonetone.com/#{login}"
  end
  
  def printable_bio
    BlueCloth::new(self.bio).to_html
  end
  
  def website
    self[:website] || site
  end
  
  def name
    self[:display_name] || login
  end
  
  def self.dummy_pic(size)
    find(:first).dummy_pic(size)
  end
  
  def listens_average
    (self.listens_count.to_f / ((((Time.now - self.assets.find(:all, :limit => 1, :order => 'created_at').first.created_at)  / 60 / 60 / 24 )).ceil)).ceil
  end
  
  def dummy_pic(size)
    case size
      when :album then 'no-pic-200.png'
      when :large then 'no-pic-125.png'
      when :small then 'no-pic-50.png'
      when nil then 'no-pic-200.jpg' 
    end
  end
  
  def avatar(size = nil)
    return dummy_pic(size) unless self.has_pic?
    self.pic.public_filename(size) 
  end
  
  def self.paginate_by_params(params)
    case params[:sort]
    when 'recently_joined' 
      self.activated.paginate(:all, :per_page => 15, :page => params[:page])
    when 'monster_uploaders'
      self.musicians.paginate(:all,:per_page => 15, :page => params[:page])
    when 'dedicated_listeners'
      @entries = WillPaginate::Collection.create((params[:page] || 1), 15) do |pager|
        # returns an array, like so: [User, number_of_listens]
        result = Listen.count(:all, :include => :listener, :order => 'count_all DESC', :conditions => 'listener_id != ""', :group => :listener, :limit => pager.per_page, :offset => pager.offset)

        # inject the result array into the paginated collection:
        pager.replace(result)
        
        unless pager.total_entries
          # the pager didn't manage to guess the total count, do it manually
          pager.total_entries = Listen.count(:listener_id, :conditions => 'listens.listener_id != ""')
        end
      end
    when 'last_uploaded'
     @entries = WillPaginate::Collection.create((params[:page] || 1), 15) do |pager|
        distinct_users = Asset.find(:all, :select => 'DISTINCT user_id', :order => 'assets.created_at DESC', :limit => pager.per_page, :offset => pager.offset)
              
        pager.replace(distinct_users.collect(&:user)) # only send back the users
        
        unless pager.total_entries
          # the pager didn't manage to guess the total count, do it manually
          pager.total_entries = User.count(:all, :conditions => 'assets_count > 0')
        end  
      end
    else # last_seen
      self.recently_seen.paginate(:all, :page => params[:page], :per_page => 15)
    end
  end
  
  
  ###### login related shit
   # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  # Activates the user in the database.
   def activate
     @activated = true
     self.activated_at = Time.now.utc
     self.activation_code = nil
     save(false)
   end
   

   def activated?
     activation_code.nil?
   end

   # Returns true if the user has just been activated.
   def pending?
     @activated
   end
  
  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  
  def self.search(query, options = {})
    with_scope :find => { :conditions => build_search_conditions(query) } do
      find :all, options
    end
  end
  
  def self.build_search_conditions(query)
    query && ['LOWER(display_name) LIKE :q OR LOWER(login) LIKE :q', {:q => "%#{query}%"}]
  end
  
  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :email << :token << :token_expires_at << :crypted_password << :identity_url << :fb_user_id << :activation_code << :admin << :salt
    super
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  
  def reset_login_key!
    self.token = Digest::SHA1.hexdigest(Time.now.to_s + crypted_password.to_s + rand(123456789).to_s).to_s
    # this is not currently honored
    self.token_expires_at = Time.now.utc+1.year
    save!
    token
  end
  
  alias_method :reset_token!, :reset_login_key!
  
  protected
  
  def make_first_user_admin
    self.admin = true if User.count == 0
  end

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end

  
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
end

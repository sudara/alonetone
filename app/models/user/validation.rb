require 'digest/sha1'
class User
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
  validates_length_of       :bio, :within => 0..500, :message => "can't be empty (or longer than 600 characters)", :on => :update

  validates_format_of       :identity_url, :with => /^https?:\/\//i, :allow_nil => true
  validates_format_of       :itunes, :with => /^phobos.apple.com\/WebObjects\/MZStore.woa\/wa\//i, :allow_blank => true, :message => 'link must be a link to the itunes store'

  # Virtual attribute for the unencrypted password
  attr_accessor :password
  before_save :encrypt_password


  # Methods related to validation
  before_save { |u| u.display_name = u.login if u.display_name.blank? }
  before_validation { |u| u.identity_url = nil if u.identity_url.blank? }
  
  def activated?
    activation_code.nil?
  end

  # Returns true if the user has just been activated
  def pending?
    @activated
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
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

  def enable_plus
    self[:plus_enabled] = true
    self.save
  end

  protected
  
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
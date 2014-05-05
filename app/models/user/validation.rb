class User
  # Validations
  validates_length_of       :display_name, :within => 3..50, :allow_blank => true
  validates_length_of       :bio, :within => 0..1000, :message => "can't be empty (or longer than 1000 characters, keep it short and simple!)", :on => :update, :allow_blank => true

  validates_length_of       :email, :within => 3..40       
  validates_uniqueness_of   :email, :case_sensitive => false
  
  validates_uniqueness_of   :login  
  validates_format_of       :login, :with => /\A[a-z0-9-]+\z/, :message => ' must be lowercase and only made from numbers and letters'
  validates_length_of       :login, :within => 3..40

  validates_format_of       :identity_url, :with => /https?:\/\//i, :allow_nil => true
  validates_format_of       :itunes, :with => /(phobos|itunes).apple.com/i, :allow_blank => true, :message => 'link must be a link to the itunes store'

  # Methods related to validation
  before_save { |u| u.display_name = u.login if u.display_name.blank? }
  before_validation { |u| u.identity_url = nil if u.identity_url.blank? }
  
  
  # tokens and activation
  def clear_token!
    update_attribute(:perishable_token, nil)
  end
  
  def active?
    perishable_token == nil
  end

  def activate!
    !active? ? clear_token! : false
  end 

  def self.find_by_login_or_email(login)
    User.find_by_login(login) || User.find_by_email(login)
  end

  def enable_plus
    self[:plus_enabled] = true
    self.save
  end
end

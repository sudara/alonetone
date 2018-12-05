class User
  # Validations
  validates_length_of       :display_name, within: 3..50, allow_blank: true

  validates_length_of       :email, within: 3..40
  validates_uniqueness_of   :email, case_sensitive: false

  validates_uniqueness_of   :login
  validates_format_of       :login, with: /\A[a-z0-9-]+\z/, message: ' must be lowercase and only made from numbers and letters'
  validates_length_of       :login, within: 3..40

  # Methods related to validation
  before_save { |u| u.display_name = u.login if u.display_name.blank? }

  # tokens and activation
  def clear_token!
    update_attribute(:perishable_token, nil)
  end

  def active?
    perishable_token.nil?
  end

  def activate!
    !active? ? clear_token! : false
  end

  def self.find_by_login_or_email(login)
    User.find_by_login(login) || User.find_by_email(login)
  end
end

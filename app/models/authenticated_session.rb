# frozen_string_literal: true

# Deals with session data related to an authenticated session.
class AuthenticatedSession
  SESSION_KEY = 'authenticated_session'

  include ActiveModel::Model

  # The Rails session object used to retrieve and store the authenticated
  # session.
  attr_accessor :session
  # User's login when creating a new session.
  attr_accessor :login
  # User's password when creating a new session.
  attr_accessor :password

  # Returns the user for the session or credentials. Note that this does NOT
  # mean the user is authenticated!
  def user
    @user ||= find_with_session || find_by_login
  end

  # A hash that can be used to represent the authenticated session.
  def to_hash
    { 'user_id' => user&.id }.compact
  end

  # Returns true if the password matches the user's password.
  def correct_password?
    !!user&.password?(password)
  end

  # Returns true if the user is present and active.
  def user_active?
    !!user&.active?
  end

  # Saves details to the Rails session. Return false when it fails.
  def save
    return false unless correct_password?
    return false unless user_active?

    session[SESSION_KEY] = to_hash
    true
  end

  def destroy
    return false unless session.key?(SESSION_KEY)

    session.delete(SESSION_KEY)
    true
  end

  private

  def user_id
    return nil unless session.key?(SESSION_KEY)
    return nil unless session[SESSION_KEY]

    session[SESSION_KEY]['user_id']
  end

  def find_with_session
    return nil unless user_id

    User.find_by(id: user_id)
  end

  def find_by_login
    return nil unless login.present?

    User.find_by(login: login)
  end
end

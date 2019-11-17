# frozen_string_literal: true

# Implements controller helper methods to deal with authentication.
module Authentication
  def current_user_session
    return @current_user_session if defined?(@current_user_session)

    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session&.user
  end

  def logged_in?
    !!current_user
  end
end

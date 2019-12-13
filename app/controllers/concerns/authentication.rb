# frozen_string_literal: true

# Implements controller helper methods to deal with authentication.
module Authentication
  # Returns the current user session from Authlogic
  def current_user_session
    return @current_user_session if defined?(@current_user_session)

    @current_user_session = UserSession.find
  end

  # Returns the current authenticated session from Alonetone's own implementation.
  def authenticated_session
    return @authenticated_session if defined?(@authenticated_session)

    @authenticated_session = AuthenticatedSession.new(session: session)
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session&.user || authenticated_session&.user
  end

  def logged_in?
    !!current_user
  end
end

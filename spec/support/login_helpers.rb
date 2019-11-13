# frozen_string_literal: true

require 'authlogic/test_case'

module RSpec
  module Support
    module LoginHelpers
      # Creates an authenticated session for the user by changing the current
      # test request. User passed to this method can either be a users fixture
      # label or a User instance.
      #
      # Can be used in controller and view specs.
      def login(user)
        user = user.is_a?(User) ? user : users(user)
        UserSession.create!(login: user.login, password: 'test', remember_me: true)
      end

      # Creates an authenticated session for the user by interacting with the
      # current integration session.
      #
      # Should be used in request specs.
      def create_user_session(user)
        post(
          '/user_sessions',
          params: { user_session: { login: user.login, password: 'test' } }
        )
      end
    end
  end
end

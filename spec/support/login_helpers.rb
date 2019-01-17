# frozen_string_literal: true

require 'authlogic/test_case'

module RSpec
  module Support
    module LoginHelpers
      include Authlogic::TestCase

      def login(user)
        login_as = user.is_a?(User) ? user : users(user)

        expect(session = UserSession.create(login_as)).to be_truthy
        allow(controller).to receive(:current_user_session).and_return(session)
        allow(controller).to receive(:current_user).and_return(login_as)
      end

      def logout
        UserSession.find.destroy if UserSession.find
      end

      def create_user_session(user)
        post(
          '/user_sessions',
          params: { user_session: { login: user.login, password: 'test' } }
        )
      end
    end
  end
end

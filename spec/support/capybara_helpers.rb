# frozen_string_literal: true

module RSpec
  module Support
    module CapybaraHelpers
      def logged_in(user=:arthur)
        visit new_user_session_path

        within '#new_user_session' do
          fill_in 'user_session_login', with: users(user).login
          fill_in 'user_session_password', with: 'test'
          click_button 'Come on in...'
        end
        yield
        visit '/logout'
      end
    end
  end
end

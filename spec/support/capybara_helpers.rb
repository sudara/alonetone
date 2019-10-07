# frozen_string_literal: true

module RSpec
  module Support
    module CapybaraHelpers

      def pause_animations
        page.execute_script("TweenMax.globalTimeScale(0)")
        page.execute_script("whilePlayingCallbackFrequency = 2000")
      end

      def resume_animations
        page.execute_script("TweenMax.globalTimeScale(1)")
        page.execute_script("whilePlayingCallbackFrequency = 100")
      end

      def with_animations_paused
        pause_animations
        yield
        resume_animations
      end

      def fast_forward_animations
        page.execute_script("TweenMax.globalTimeScale(10)")
        page.execute_script("whilePlayingCallbackFrequency = 100")
        sleep(0.2)
      end

      def logged_in(user=:arthur)
        visit new_user_session_path

        within '#login_form' do
          fill_in 'user_session[login]', with: users(user).login
          fill_in 'user_session[password]', with: 'test'
          click_button 'Come on in...'
        end
        yield
        visit '/logout'
      end
    end
  end
end

# frozen_string_literal: true

module RSpec
  module Support
    module CapybaraHelpers
      def switch_themes
        page.click_on class: 'profile_link'
        page.click_on class: 'switch_to_theme'
      end

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
        page.execute_script("TweenMax.globalTimeScale(2)")
        page.execute_script("whilePlayingCallbackFrequency = 10")
        sleep(0.1)
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

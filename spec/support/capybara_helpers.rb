# frozen_string_literal: true

module RSpec
  module Support
    module CapybaraHelpers
      def switch_themes
        # Wait for the user-dropdown Stimulus controller to connect before
        # clicking; otherwise on slow CI the click lands before the action
        # handler is wired up and the menu never opens. The controller adds
        # the `connected` class from its connect() callback.
        page.assert_selector('.user_dropdown.connected')
        page.click_on class: 'profile_link'
        page.click_on class: 'switch_to_theme'
      end

      def pause_animations
        page.execute_script("Alonetone.gsap.globalTimeline.timeScale(0)")
      end

      def resume_animations
        page.execute_script("Alonetone.gsap.globalTimeline.timeScale(1)")
      end

      def with_animations_paused
        pause_animations
        yield
        resume_animations
      end

      def fast_forward_animations
        page.execute_script("Alonetone.gsap.globalTimeline.timeScale(10)")
        sleep(0.1)
      end

      def logged_in(user=:arthur)
        visit new_user_session_path

        within '#login_form' do
          fill_in 'user_session[login]', with: users(user).login
          fill_in 'user_session[password]', with: 'test'
          click_button 'Come on in...'
        end
        # click_button can return before Selenium actually dispatches the POST and
        # follows the redirect. Wait for a logged-in-only element before yielding,
        # otherwise a subsequent `visit` can race ahead and hit the unauthenticated
        # state (redirecting to /login and silently failing the test setup).
        expect(page).to have_css('.user_dropdown')
        yield
      end
    end
  end
end

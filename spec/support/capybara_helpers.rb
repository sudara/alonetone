# frozen_string_literal: true

module RSpec
  module Support
    module CapybaraHelpers
      def switch_themes
        # Wait for Stimulus to wire up the page before clicking; otherwise on
        # slow CI the first click lands before the user-dropdown action handler
        # is attached and the menu never opens.
        wait_for_stimulus
        page.click_on class: 'profile_link'
        page.click_on class: 'switch_to_theme'
      end

      # Signal emitted from application.js on turbo:load, by which point
      # Stimulus has processed the initial DOM and every data-controller on
      # the page is connected.
      def wait_for_stimulus
        page.assert_selector('body[data-stimulus-ready]')
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

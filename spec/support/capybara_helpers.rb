# frozen_string_literal: true

module RSpec
  module Support
    module CapybaraHelpers
      # Auto-wait for Stimulus on every navigation in js feature specs.
      # Since the Shakapacker 7 / Webpack 5 upgrade, the application bundle
      # loads async chunks, so DOMContentLoaded no longer implies controllers
      # are connected. Without this, any click/hover that targets a
      # Stimulus-wired element races the MutationObserver and flakes.
      def visit(*args, **kwargs)
        super
        wait_for_stimulus if Capybara.current_driver == :alonetone
      end

      def switch_themes
        # Native click on profile_link is intermittently lost in --headless=new
        # Chrome (the dropdown doesn't open). JS-click guarantees dispatch.
        page.execute_script('arguments[0].click()', find('.user_dropdown .profile_link'))
        find('.user_dropdown_menu', visible: true)
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

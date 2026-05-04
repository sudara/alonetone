# frozen_string_literal: true

module RSpec
  module Support
    module CapybaraHelpers
      def switch_themes
        find('.user_dropdown .profile_link').click
        find('.user_dropdown_menu', visible: true)
        page.click_on class: 'switch_to_theme'
      end

      # Capybara's find-then-click holds an eager ElementHandle that goes stale when the region re-renders;
      # this routes through a Playwright Locator (lazy query, re-resolves at action time).
      # The selector is resolved against the full document, so this ignores any enclosing `within(...)`.
      def pw_click(selector, x: nil, y: nil)
        page.driver.with_playwright_page do |pw_page|
          options = (x && y) ? { position: { x: x, y: y } } : {}
          pw_page.locator(selector).first.click(**options)
        end
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
        expect(page).to have_css('.user_dropdown')
        yield
      end
    end
  end
end

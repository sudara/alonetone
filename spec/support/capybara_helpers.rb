# frozen_string_literal: true

module RSpec
  module Support
    module CapybaraHelpers
      def switch_themes
        find('.user_dropdown .profile_link').click
        find('.user_dropdown_menu', visible: true)
        page.click_on class: 'switch_to_theme'
      end

      # Capybara node handles go stale between find and click when the element re-renders; locators re-resolve.
      # The selector is resolved against the full document, so this ignores any enclosing `within(...)`.
      def click_at(selector, x:, y:)
        page.driver.with_playwright_page do |pw_page|
          pw_page.locator(selector).first.click(position: { x: x, y: y })
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

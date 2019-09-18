# frozen_string_literal: true

module RSpec
  module Support
    module CapybaraHelpers

      def pause_animations
        page.execute_script("TweenMax.globalTimeScale(0)")
      end

      def resume_animations
        page.execute_script("TweenMax.globalTimeScale(1)")
      end

      def convert_canvas_to_image
        script = "
          function canvasToImage(selectorOrEl) {
            let canvas = typeof selectorOrEl === 'object' ? selectorOrEl : document.querySelector(selector);
            let image = document.createElement('img');
            let canvasImageBase64 = canvas.toDataURL();
            image.src = canvasImageBase64;
            image.style = 'max-width: 100%';
            canvas.setAttribute('data-percy-modified', true);
            canvas.parentElement.appendChild(image);
            canvas.style = 'display: none';
          }
          document.querySelectorAll('canvas').forEach(selector => canvasToImage(selector))"
        page.execute_script(script)
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

require "rails_helper"

RSpec.describe 'persistent player', type: :feature, js: true do
  # Auth happens over Turbo so the player bar (data-turbo-permanent) survives the
  # body swap and audio keeps playing. We tag the live #player node and prove the
  # SAME node is still on the page after logging in and back out.
  it 'keeps playing across login and logout' do
    visit '/'
    find('.asset .play_link', match: :first).click
    expect(page).to have_css('#player.visible')
    page.execute_script("document.getElementById('player').dataset.specMarker = 'kept'")

    # Log in via Turbo (header link -> form submit), not a fresh page load.
    find('.login_button').click
    within '#login_form' do
      fill_in 'user_session[login]', with: users(:arthur).login
      fill_in 'user_session[password]', with: 'test'
      click_button 'Come on in...'
    end
    expect(page).to have_css('.user_dropdown')
    expect(page).to have_css("#player[data-spec-marker='kept']")

    open_user_menu
    logout = find('.logout_item')
    # Turbo-driven so playback survives, but prefetch MUST stay off or hovering
    # the link would silently log the user out.
    expect(logout['data-turbo']).to be_nil
    expect(logout['data-turbo-prefetch']).to eq('false')
    logout.click

    expect(page).to have_css('.login_button')
    expect(page).to have_css("#player[data-spec-marker='kept']")
  end

  def open_user_menu
    find('.user_dropdown .profile_link').click
    find('.user_dropdown_menu', visible: true)
  end
end

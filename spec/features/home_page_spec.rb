require "rails_helper"

RSpec.describe 'home page', type: :feature, js: true do
  it 'renders' do
    visit '/'
    expect(page).to have_selector('#home_latest_area', visible: true)
    expect(page).not_to have_selector('.profile_link')

    track_chunk = find(".asset", match: :first)
    track_chunk.find(".play_link").click

    expect(track_chunk).to have_selector('.private_check_box label', visible: true)
    expect(track_chunk).to have_no_selector('.add_to_favorites')

    track_chunk.find('.private_check_box label').click

    expect(track_chunk).to have_selector('span.only_user_name', visible: true)

    track_chunk.find('textarea').fill_in with: "Hey this is a comment from a guest"

    # private checkbox is technically offscreen, but we still want to confirm it's checked
    expect(track_chunk.find('.private_check_box .private', visible: :all)).to be_checked
    page.percy_snapshot('Home as Guest')

    akismet_stub_response_ham
    track_chunk.find('input[type=submit]').click
    expect(track_chunk.find('.ajax_waiting')).to have_text('Submitted, thanks!')
  end

  it 'renders logged in' do
    logged_in(:arthur) do
      visit '/'
      expect(page).to have_selector('.profile_link')
      # let's snap the dark theem nav while we are at it
      switch_themes
      expect(page).to have_selector('.profile_link')

      track = find(".asset", match: :first)
      track.find(".play_link").click

      expect(track).to have_selector('.add_to_favorites')
      expect(page).to have_css('#player.visible')

      find('#player .player_waveform').click # seek in the persistent player
      track.find(".play_link").click # pause the track
      expect(track).to have_selector('.add_to_favorites')
      page.percy_snapshot('Home as User')
    end
  end

  it 'properly runs javascript and reports console errors', :allow_js_errors do
    visit '/'
    page.execute_script("console.error('hello from capybara')")
    expect(@browser_console_messages).to include(
      a_hash_including(level: 'error', message: a_string_including('hello from capybara'))
    )
  end
end

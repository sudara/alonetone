require "rails_helper"

RSpec.describe 'home page', type: :feature, js: true do
  it 'renders' do
    visit '/'
    expect(page).to have_selector('#home_latest_area', visible: true)
    expect(page).not_to have_selector('.profile_link')

    track_chunk = find(".asset", match: :first)
    track_chunk.click

    expect(page).to have_selector('.private_check_box label')
    expect(track_chunk).not_to have_selector('.add_to_favorites')

    # capybara should be waiting here but isn't
    sleep 0.2
    track_chunk.find('.private_check_box label').click
    expect(page).to have_selector('span.only_user_name')

    # checkbox is offscreen, but we still want to confirm it's checked
    expect(track_chunk.find('.private_check_box .private', visible: false)).to be_checked
    Percy.snapshot(page, name: 'Home as Guest')
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
      expect(track).to have_selector('.stitches_seek')
      expect(track).to have_selector('.stitches_seek .loaded') # only shows up on playback
      track.find(".stitches_seek").click # click in the middle of the seekbar
      track.find(".play_link").click # pause the track
      expect(track).to have_selector('.add_to_favorites')
      Percy.snapshot(page, name: 'Home as User')
    end
  end
end

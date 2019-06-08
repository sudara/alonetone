require "rails_helper"

RSpec.describe 'playlists', type: :feature, js: true do
  it 'renders track and cover pages' do
    logged_in do
      visit 'henriwillig/playlists/polderkaas'
      first_track_play_button = find('ul.tracklist li:first-child a:first-child')
      first_track_play_button.hover
      Percy.snapshot(page, name: 'Playlist Cover')

      first_track_play_button.click
      # The above click will be an ajax request
      # And in some cases our Snapshot will fire before the DOM is updated
      # Capybara is good at waiting if we specify an expectation
      # so let's specify one before we snap
      expect(page).to have_selector(".player")

      sleep 1

      # Ideally we'd want to see the seekbar progress to prove playback worked.
      # However, the seekbar is a canvas element which we can't test.
      # Intsead, can use the svg animation to prove playback worked
      # However, the following selector is shown on both loading and pause
      expect(page).to have_selector('.largePlaySVG .pauseContainer', visible: true)

      # TODO: Make sure the animated loader is no longer showing
      # expect(page).to have_selector('.largePlaySVG .spinballGroup', visible: false)
      Percy.snapshot(page, name: 'Playlist Track')
    end
  end
end
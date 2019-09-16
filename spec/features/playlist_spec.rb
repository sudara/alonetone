require "rails_helper"

RSpec.describe 'playlists', type: :feature, js: true do
  it 'renders track and cover pages' do
    logged_in do
      visit 'henriwillig/playlists/polderkaas'

      first_track = find('ul.tracklist li:first-child')
      first_track.hover
      Percy.snapshot(page, name: 'Playlist Cover')

      first_track.find('a:first-child').click

      # The above click will be an ajax request
      # And in some cases our Snapshot will fire before the DOM is updated
      # Capybara is good at waiting if we specify an expectation
      # so let's specify one before we snap
      pause_animations
      expect(page).to have_selector(".player")
      convert_canvas_to_image
      Percy.snapshot(page, name: 'Playlist Track Loading')

      # Navigating away and back, we should still be playing
      resume_animations
      second_track = find('ul.tracklist li:last-child')
      second_track.click
      first_track.click
      sleep 1
      find('.waveform').click(x: 200, y: 10)
      find('.play-button-container a').click
      sleep 0.5
      convert_canvas_to_image
      Percy.snapshot(page, name: 'Playlist Track Play, Seek, Pause')
    end
  end

  it 'renders playlist editing' do
    logged_in(:henri_willig) do
      visit 'henriwillig/playlists/polderkaas/edit'

      # remove second track
      find('.sortable .asset:last-child .remove').click
      expect(page).to have_selector('.sortable .asset', count: 1)

      # add 2 new tracks
      first_upload = find('#your_uploads .asset:nth-child(1) .add')
      first_upload.click
      first_upload.click
      expect(page).to have_selector('.sortable .asset', count: 3)

      # Move "Manfacturer of the Finest Cheese" to be the last song
      first_track = find('.sortable .asset:first-child')
      last_track = find('.sortable .asset:last-child')
      first_track.drag_to(last_track)
      #expect(find('.sortable .asset:last-child .track_link').text).to eql('Manufacturer of the Finest Cheese')

      Percy.snapshot(page, name: 'Playlist Edit')
    end
  end
end

require "rails_helper"

RSpec.describe 'playlists', type: :feature, js: true do

  it 'renders track and cover pages' do
    logged_in(:arthur) do
      visit 'henriwillig/playlists/polderkaas'
      first_track = find('ul.tracklist li:first-child')

      # I hoped we could pause and resume animations as needed
      # But we require absolutely 0 DOM variation to please Percy
      # Note: this only pauses GSAP animations
      with_animations_paused do
        first_track.hover
        Percy.snapshot(page, name: 'Playlist Cover')

        # This click will be an ajax request
        # And in some cases our Snapshot will fire before the DOM is updated
        # Capybara is good at waiting if we specify an expectation
        # so let's specify one before we snap
        first_track.find('a:first-child').click
        expect(page).to have_selector(".player")
        Percy.snapshot(page, name: 'Playlist Track Loading')
      end

      # Navigating away and back, we should still be playing
      second_track = find('ul.tracklist li:last-child')
      second_track.click
      first_track.click

      switch_themes

      with_animations_paused do
        find('.waveform').click(x: 200, y: 10) # seek
        find('.waveform').click(x: 200, y: 10) # set predictable-ish pausing spot
        find('.play_button_container a').click # pause

        # The time between seeking and pausing is variable
        # So we manually adjust the playhead end state to the exact
        # same position for the percy snap.
        Percy.snapshot(page,
          name: 'Playlist Track Play, Seek, Pause',
          percy_css: "#waveform_reveal { left: -335px !important; }
            .progress_container_inner { left: 33% !important; }")
      end
    end
  end

  it 'renders playlist editing' do
    logged_in(:henri_willig) do
      visit 'henriwillig/playlists/polderkaas/edit'

      # add a playlist image
      attach_file('playlist_cover_image', 'spec/fixtures/files/cheshire_cheese.jpg', make_visible: true)
      find('input[name="commit"]').click
      expect(find(".cover img")['src']).to have_content('cheshire_cheese.jpg')

      pause_animations

      # test that we can remove second track
      find('.sortable .asset:last-child .remove').click
      expect(page).to have_selector('.sortable .asset', count: 1)

      # add 2 new tracks
      first_upload = find('#your_uploads .asset:nth-child(1) .add')
      first_upload.click
      expect(page).to have_selector('.sortable .asset', count: 2)
      first_upload.click
      expect(page).to have_selector('.sortable .asset', count: 3)

      # Ensure custom checkboxes are happy
      find('.edit_playlist_info_right_column_private_and_hidden label').click
      find('.edit_playlist_info_right_column_private_and_hidden label').click

      # Move "Manfacturer of the Finest Cheese" to be the last song
      first_track_handle = find('.sortable .asset:first-child .drag_handle')
      last_track = find('.sortable .asset:last-child')
      first_track_handle.drag_to(last_track)
      expect(find('.sortable .asset:last-child .track_link').text).to eql('Manufacturer of the Finest Cheese')
      Percy.snapshot(page, name: 'Playlist Edit')
    end
  end
end

require "rails_helper"

RSpec.describe 'playlists', type: :feature, js: true do
  # The buffered-fill rect grows on a CSS width transition that GSAP pausing
  # doesn't touch, so pin it to a fixed width for a stable Percy capture.
  FREEZE_BUFFERED_FILL = '.player_waveform_loaded_reveal { width: 500px !important; transition: none !important; }'.freeze

  it 'renders track and cover pages' do
    logged_in(:arthur) do
      visit 'henri_willig/playlists/polderkaas'
      first_track = find('ul.tracklist li:first-child')

      first_track.hover
      expect(first_track).to have_css(':hover')
      page.percy_snapshot('Playlist Cover')

      # Percy needs zero DOM variation between captures, so freeze GSAP animations.
      with_animations_paused do
        first_track.find('a.play_button').click
        # Play swaps the cover view for the track detail and reveals the
        # persistent player at the bottom of the page.
        expect(page).to have_css('#player.visible')
        expect(page).to have_css('.track_content .track_post')
        # Points are fetched on demand, so wait for them or the snapshot races an
        # empty SVG. visible: :all is required: the polygon lives in <defs>.
        expect(page).to have_xpath('//*[@id="player_waveform_points" and string-length(@points) > 0]', visible: :all)
        page.percy_snapshot('Playlist Track Loading', percy_css: FREEZE_BUFFERED_FILL)
      end

      # Navigating away and back, the persistent player keeps playing
      second_track = find('ul.tracklist li:last-child')
      second_track.click
      first_track.click
      expect(page).to have_css('#player.visible')

      switch_themes

      with_animations_paused do
        pw_click('#player .player_waveform', x: 200, y: 10) # seek
        pw_click('#player .player_play')                    # pause
        # Listen-counting through this seek/pause flow is racy in headless
        # mode; the count assertion lives in assets_controller_spec instead.
        expect(page).to have_css('ul.tracklist li.is-current:not(.is-playing)')

        # The time between seeking and pausing is variable, so pin the playhead
        # to an exact position for a deterministic Percy capture.
        page.percy_snapshot('Playlist Track Play, Seek, Pause',
          percy_css: ".player_progress { left: 33% !important; }
            .player_waveform_reveal { x: -170px !important; }
            #{FREEZE_BUFFERED_FILL}")
      end
    end
  end

  it 'renders playlist editing' do
    logged_in(:henri_willig) do
      visit 'henri_willig/playlists/polderkaas/edit'

      # add a playlist image
      attach_file('playlist_cover_image', 'spec/fixtures/files/cheshire_cheese.jpg', make_visible: true)
      find('input[name="commit"]').click
      expect(page).to have_css('.cover img[src*="cheshire_cheese.jpg"]')

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
      first_track_handle.drag_to(last_track, delay: 0.1)
      expect(find('.sortable .asset:last-child .track_link').text).to eql('Manufacturer of the Finest Cheese')
      page.percy_snapshot('Playlist Edit')
    end
  end
end

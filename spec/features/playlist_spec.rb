require "rails_helper"

RSpec.describe 'playlists', type: :feature, js: true do
  it 'renders track and cover pages' do
    logged_in do
      visit 'henriwillig/playlists/polderkaas'
      first_track = find('ul.tracklist li:first-child')
      first_track.hover
      Percy.snapshot(page, name: 'Playlist Cover')

      first_track.click
      # The above click will be an ajax request
      # And in some cases our Snapshot will fire before the DOM is updated
      # Capybara is good at waiting if we specify an expectation
      # so let's specify one before we snap
      expect(page).to have_selector(".player")

      # TODO: Figure out a way to snapshot playback
      Percy.snapshot(page, name: 'Playlist Track')
    end
  end
end
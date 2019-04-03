require "rails_helper"

RSpec.describe 'playlists', type: :feature, js: true do
  it 'renders track and cover pages' do
    logged_in do
      visit 'henriwillig/playlists/polderkaas'
      first_track = find('ul.tracklist li:first-child')
      first_track.hover
      Percy::Capybara.snapshot(page, name: 'Playlist Cover')

      first_track.click
      Percy::Capybara.snapshot(page, name: 'Playlist Track')
    end
  end
end
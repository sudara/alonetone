require "rails_helper"

RSpec.describe 'playlists', type: :feature, js: true do
  it 'renders track and cover pages' do
    logged_in do
      visit 'henriwillig/playlists/polderkaas/manufacturer-of-the-finest-cheese'
      find('ul.tracklist li:first-child').hover
      Percy::Capybara.snapshot(page, name: 'Playlist Track')

      find('a.small-cover').click
      Percy::Capybara.snapshot(page, name: 'Playlist Cover')
    end
  end
end
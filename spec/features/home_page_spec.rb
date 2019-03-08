require "rails_helper"

RSpec.describe 'home page', type: :feature, js: true do
  it 'renders' do
    visit '/'
    expect(page).to have_selector('#home_latest_area', visible: true)
    expect(page).not_to have_selector('.profile_link')
    track_chunk = find(".asset", match: :first)
    track_chunk.click
    expect(track_chunk).not_to have_selector('.add_to_favorites')
    Percy::Capybara.snapshot(page, name: 'as guest')
  end

  it 'renders logged in' do
    logged_in do
      visit '/'
      expect(page).to have_selector('.profile_link')
      track_chunk = find(".asset", match: :first)
      track_chunk.click
      expect(track_chunk).to have_selector('.add_to_favorites')
      Percy::Capybara.snapshot(page, name: 'as user')
    end
  end
end

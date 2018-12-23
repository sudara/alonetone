require "rails_helper"

RSpec.describe 'home page renders fine', type: :feature, js: true do
  it 'shows the dropdown menu when clicked' do
    visit '/'
    expect(page).to have_selector('#home_latest_area', visible: true)

    Percy::Capybara.snapshot(page, name: 'as guest')
  end
end
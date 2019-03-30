require "rails_helper"

RSpec.describe 'single track playing', type: :feature, js: true do
  it 'renders' do
    visit '/sudara/tracks/song1'
    play_button = find(".play-button a")
    play_button.click
    Percy::Capybara.snapshot(page, name: 'Single Track Play')
  end
end
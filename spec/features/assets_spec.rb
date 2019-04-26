require "rails_helper"

RSpec.describe 'single track playing', type: :feature, js: true do
  it 'renders' do
    visit '/sudara/tracks/song1'
    play_button = find(".play-button a")

    # TODO: find a way to accomplish this without creating jank
    # play_button.click
    Percy.snapshot(page, name: 'Single Track Play')
  end
end
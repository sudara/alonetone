require "rails_helper"

RSpec.describe 'tracks', type: :feature, js: true do
  it 'renders assets#show' do
    visit '/sudara/tracks/song1'
    play_button = find(".play_button a")

    page.percy_snapshot('Single Track Page')

    # seek halfway
    # find('.waveform').click
    # page.percy_snapshot('Single Track Seeking')
  end

  it 'renders assets#mass_edit' do
    logged_in do
      visit 'arthur/tracks/mass_edit'
      page.percy_snapshot('Mass Edit')
    end
  end

  it 'flashes after editing a single track' do
    logged_in do
      visit '/arthur/tracks/song1/edit'
      within('.track_edit') do
        first("input[type='text']").set("Song1 Renamed")
        first('input[name="commit"]').click
      end
      expect(page).to have_css('.flash', text: 'Saved!')
    end
  end
end

require "rails_helper"

RSpec.describe 'thredded', type: :feature, js: true do
  it 'renders' do
    logged_in(:sudara) do
      visit '/forums'
      switch_themes

      expect(page).to have_text "Gear Talk"
      Percy.snapshot(page, name: 'Forums Index', enable_javascript: true)
    end
  end
end

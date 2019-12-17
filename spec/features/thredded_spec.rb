require "rails_helper"

RSpec.describe 'thredded', type: :feature, js: true do
  it 'renders' do
    visit '/forums'
    switch_themes

    # Wait for js to append a column class
    expect(page).to have_text "Gear Talk"
    Percy.snapshot(page, name: 'Forums Index', enable_javascript: true)
  end
end
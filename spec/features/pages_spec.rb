require "rails_helper"

RSpec.describe 'home page', type: :feature, js: true do
  it 'renders' do
    visit '/about'
    expect(page).to have_selector('li.current')
    Percy.snapshot(page, name: 'About Page')
  end
end
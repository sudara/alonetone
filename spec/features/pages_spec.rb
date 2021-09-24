require "rails_helper"

RSpec.describe 'about page', type: :feature, js: true do
  it 'renders' do
    visit '/about'

    # Wait for js to append a column class
    expect(page).to have_selector('.sub_nav_inner', class: /column/)
    page.percy_snapshot('About Page', enable_javascript: true)
  end
end

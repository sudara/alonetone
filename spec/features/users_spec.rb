require "rails_helper"

RSpec.describe 'users', type: :feature, js: true do
  it 'renders users/edit' do
    logged_in(:jamie_kiesl) do
      visit '/users/jamiek/edit'
      page.percy_snapshot('Edit Profile')
    end
  end

  it 'renders user home' do
    visit '/henri_willig'
    page.percy_snapshot('Profile')
  end
end

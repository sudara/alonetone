require "rails_helper"

RSpec.describe 'users', type: :feature, js: true do
  it 'renders users/edit' do
    logged_in(:jamie_kiesl) do
      visit '/users/jamie_kiesl/edit'
      Percy.snapshot(page, name: 'Edit Profile')
    end
  end

  it 'renders user home' do
    visit '/henriwillig'
    Percy.snapshot(page, name: 'Profile')
  end
end

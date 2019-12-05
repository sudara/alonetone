require "rails_helper"

RSpec.describe 'Get An Account', type: :feature, js: true do
  it 'renders the form with errors' do
    visit '/get_an_account'
    submit = find("form input[type=submit]")
    submit.click
    expect(page).to have_selector('#error_explanation', visible: true)

    Percy.snapshot(page, name: 'Single Track Page')

  end
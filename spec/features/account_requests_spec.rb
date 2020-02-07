require "rails_helper"

RSpec.describe 'Get An Account', type: :feature, js: true do
  it 'renders the form with errors' do
    visit '/get_an_account'
    submit = find("form input[type=submit]")
    submit.click
    expect(page).to have_selector('#error_explanation', visible: true)

    Percy.snapshot(page, name: 'Sign up')
  end

  it 'submits the form and succeeds' do
    visit '/get_an_account'
    page.fill_in 'Email', with: "someband@hotmail.com"
    page.fill_in 'account_request_login', with: 'someband456'
    page.fill_in 'account_request_details', with: "This is a story of a very cool band with 40 characters of story to tell"
    page.choose 'Musician'
    page.click_on 'Get On The List'

    expect(page).to have_content('Thank you')
  end
end

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

  it 'renders assets#edit' do
    logged_in do
      visit 'arthur/tracks/mass_edit'
      first("input[type='text']").set("New Title")
      akismet_stub_response_ham
      first('input[name="commit"]').click
      # Scope to the save controller's response target so we don't match the
      # layout's always-hidden .floating_feedback.ajax_success, and extend the
      # wait because the Turbo submit round-trip can exceed the 2s default on CI.
      expect(page).to have_css('[data-save-target="response"].ajax_success', wait: 10)
      sleep(1) # wait for the spinner to dissapear, it takes 500ms
      page.percy_snapshot('Single Track Edit')
    end
  end
end

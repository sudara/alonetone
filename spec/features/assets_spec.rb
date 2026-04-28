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
      # layout's always-hidden .floating_feedback.ajax_success. visible: false
      # because save_controller's gsap timeline fades the response out 4s after
      # success, so on slow CI Capybara can poll past the visible window — the
      # class is the real signal that turbo:submit-end -> save#success fired.
      expect(page).to have_css('[data-save-target="response"].ajax_success', wait: 10, visible: false)
      sleep(1) # wait for the spinner to dissapear, it takes 500ms
      page.percy_snapshot('Single Track Edit')
    end
  end

  it 'flashes after editing a single track' do
    logged_in do
      visit '/arthur/tracks/song1/edit'
      within('.track_edit') do
        first("input[type='text']").set("Song1 Renamed")
        first('input[name="commit"]').click
      end
      # The slug is regenerated from the title (Slugs concern), so the redirect
      # lands on the new permalink — but the flash is what we're asserting.
      expect(page).to have_css('.flash', text: 'Saved!')
    end
  end
end

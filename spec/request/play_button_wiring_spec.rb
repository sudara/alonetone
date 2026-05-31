require 'rails_helper'

# The persistent player queues tracks via the `tracklist` Stimulus controller, so
# every play button must live inside a `data-controller="tracklist"` ancestor or
# the click silently does nothing.
RSpec.describe 'play button wiring', type: :request do
  def play_buttons_with_tracklist_ancestor(path)
    get path
    expect(response).to be_successful
    doc = Nokogiri::HTML(response.body)
    play_links = doc.css('a.play_link, a.play_button')
    play_links.each do |link|
      wrapped = link.ancestors.any? { |a| (a['data-controller'] || '').split.include?('tracklist') }
      expect(wrapped).to be(true), "play button missing a tracklist ancestor on #{path}"
    end
    play_links.size
  end

  it 'wraps every play button on the home page' do
    expect(play_buttons_with_tracklist_ancestor(root_path)).to be > 0
  end

  it 'wraps every play button on the user home page' do
    expect(play_buttons_with_tracklist_ancestor(user_home_path('sudara'))).to be > 0
  end

  it 'wraps every play button on the listening history page' do
    play_buttons_with_tracklist_ancestor(listens_path('sudara'))
  end

  it 'wraps every play button on the comments page' do
    play_buttons_with_tracklist_ancestor(user_comments_path('sudara'))
  end
end

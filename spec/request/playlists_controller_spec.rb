# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaylistsController, type: :request do
  context "a visitor" do
    it "sees a playlist without a cover image" do
      playlist = playlists(:william_shatners_favorites)
      get "/william-shatner/playlists/bills-favorites"
      expect(response).to be_successful
      expect(response.body).to_not match_css('link[rel="preload"]')
    end

    it "sees a playlist with a cover image" do
      get "/willstudd/playlists/rockfort"
      playlist = playlists(:will_studd_rockfort)
      expect(response).to be_successful
      expect(response.body).to match_css(
        'link[href="' + playlist.cover_url(variant: :greenfield) + '"]'
      )
    end
  end
end

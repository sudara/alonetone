# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaylistsController, type: :request do
  context "a visitor" do
    it "sees a playlist without a cover image" do
      playlist = playlists(:william_shatners_favorites)
      get "/williamshatner/playlists/bills-favorites"
      expect(response).to be_successful
    end

    it "sees a playlist with a cover image" do
      get "/willstudd/playlists/rockfort"
      playlist = playlists(:will_studd_rockfort)
      expect(response).to be_successful
      expect(response.body).to match_css('link[href]')
    end
  end

  context "a musician" do
    let(:user) { users(:jamie_kiesl) }
    before do
      create_user_session(user)
    end

    it "creates a new playlist" do
      post(
        "/jamiek/playlists",
        params: {
          playlist: {
            title: '🧀 THE FUNK 🧀',
            year: '1999'
          }
        }
      )
      expect(response).to be_redirect
      uri = URI.parse(response.headers['Location'])
      expect(uri.path).to start_with('/jamiek/playlists')
      expect(uri.path).to end_with('/edit')
    end
  end

  context "deleting" do
    it "redirects to user home" do
      create_user_session(users(:arthur))
      delete("/arthur/playlists/mix-tape")
      expect(response).to redirect_to('/arthur')
      expect(response.code).to eql("303")
    end
  end

  context "editing" do
    it "redirects to new permalink" do
      create_user_session(users(:arthur))
      put(
        "/arthur/playlists/mix-tape",
        params: {
          playlist: {
            title: 'Totally New Mix'
          }
        }
      )
      expect(response).to redirect_to('/arthur/playlists/totally-new-mix/edit')
    end
  end
end

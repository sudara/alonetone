# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaylistsController, type: :request do
  context "a visitor" do
    it "sees a playlist without a cover image" do
      get "/williamshatner/playlists/bills-favorites"
      expect(response).to be_successful
    end

    it "sees a playlist with a cover image" do
      get "/willstudd/playlists/rockfort"
      playlist = playlists(:will_studd_rockfort)
      expect(response).to be_successful
      expect(response.body).to match_css('link[href]')
    end

    it "is redirected to login when editing a playlist" do
      get edit_user_playlist_path('sudara', 'owp')

      expect(response).to redirect_to('/login')
    end

    it "is redirected to login when updating a playlist" do
      put user_playlist_path('sudara', 'owp'), params: { playlist: { title: 'new title' } }

      expect(response).to redirect_to('/login')
    end

    it "is redirected to login when modifying playlist tracks or cover art" do
      playlist = playlists(:owp)
      track = playlist.tracks.first

      [
        -> { post sort_tracks_user_playlist_path('sudara', 'owp'), params: { track: [track.id] } },
        -> { post add_track_user_playlist_path('sudara', 'owp'), params: { asset_id: "asset_#{assets(:valid_mp3).id}" } },
        -> { get remove_track_user_playlist_path('sudara', 'owp'), params: { track_id: track.id } },
        -> { post attach_pic_user_playlist_path('sudara', 'owp') }
      ].each do |request|
        request.call
        expect(response).to redirect_to('/login')
      end
    end

    it "cannot delete a playlist" do
      expect do
        delete user_playlist_path('sudara', 'owp')
      end.not_to change(Playlist, :count)
      expect(response).to redirect_to('/login')
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

  context "permissions" do
    it "does not let a user edit someone else's playlist" do
      create_user_session(users(:arthur))

      get edit_user_playlist_path('sudara', 'owp')

      expect(response).not_to be_successful
    end

    it "lets a user edit their own playlist" do
      create_user_session(users(:arthur))

      get edit_user_playlist_path('arthur', 'arthurs-playlist')

      expect(response).to be_successful
    end
  end

  context "sorting" do
    it "allows sorting of playlists" do
      create_user_session(users(:sudara))
      order = playlists(:empty, :owp).map { |playlist| playlist.id.to_s }

      post sort_user_playlists_path('sudara'), params: { playlist: order }, headers: { 'X-Requested-With' => 'XMLHttpRequest' }

      expect(response).to be_successful
    end
  end

  context "pagination" do
    it "paginates the available uploads on the edit page" do
      user = users(:arthur)
      create_user_session(user)
      11.times do |i|
        asset = user.assets.build(
          title: "pagination track #{i}",
          permalink: "pagination-track-#{i}",
          mp3_file_name: "pagination-track-#{i}.mp3",
          mp3_content_type: "audio/mpeg",
          mp3_file_size: 3.megabytes,
          private: false
        )
        asset.save(validate: false)
      end

      get edit_user_playlist_path(user.login, 'arthurs-playlist')

      expect(response.body).to include("uploads_page=2")
    end
  end

  context "deleting" do
    it "redirects to user home" do
      create_user_session(users(:arthur))
      delete("/arthur/playlists/mix-tape")
      expect(response).to redirect_to('/arthur')
      expect(response.code).to eql("303")
    end

    it "does not let any old user delete a playlist" do
      create_user_session(users(:arthur))

      expect do
        delete user_playlist_path('sudara', 'owp')
      end.not_to change(Playlist, :count)
      expect(response).not_to be_successful
    end

    it "lets an admin delete any playlist" do
      create_user_session(users(:sudara))

      expect do
        delete user_playlist_path('arthur', 'arthurs-playlist')
      end.to change(Playlist, :count).by(-1)
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

    it "updates published_at" do
      playlist = playlists(:henri_willig_unpublished)
      expect(playlist.published_at).to be_nil
      expect(playlist.published).to be(false)
      create_user_session(users(:henri_willig))

      put user_playlist_path('henri_willig', 'unpublished'),
        params: { playlist: { title: 'unpublished', is_private: false } }

      expect(playlist.reload.published).to be_truthy
      expect(playlist.published_at).not_to be_nil
    end

    it "does not publish if playlist has less than 2 tracks" do
      playlist = playlists(:jamie_kiesl_playlist_with_soft_deleted_tracks)
      expect(playlist.tracks.count).to eq(1)
      create_user_session(users(:jamie_kiesl))

      put user_playlist_path('jamiek', 'jamie-playlist-with-soft-delete'),
        params: { playlist: { title: playlist.title, is_private: "0" } }

      expect(playlist.reload.published_at).to be_nil
    end
  end

  context "cover images" do
    it "lets a user upload a playlist photo" do
      create_user_session(users(:arthur))

      post attach_pic_user_playlist_path('arthur', 'arthurs-playlist'),
        params: { pic: { pic: fixture_file_upload('jeffdoessudara.jpg', 'image/jpeg') } }

      expect(flash[:notice]).to be_present
      expect(response).to redirect_to(edit_user_playlist_path(users(:arthur), 'arthurs-playlist'))
    end

    it "does not let a user upload a new photo for another user" do
      create_user_session(users(:arthur))

      post attach_pic_user_playlist_path('sudara', 'owp'),
        params: { pic: { pic: fixture_file_upload('jeffdoessudara.jpg', 'image/jpeg') } }

      expect(response).to redirect_to('/login')
    end

    it "breaks the homepage cache" do
      playlist = playlists(:arthurs_playlist)
      create_user_session(users(:arthur))

      expect do
        post attach_pic_user_playlist_path('arthur', 'arthurs-playlist'),
          params: { pic: { pic: fixture_file_upload('jeffdoessudara.jpg', 'image/jpeg') } }
      end.to change { playlist.reload.updated_at }
    end
  end

  describe "someone using the old theme" do
    it "visits a public playlist" do
      create_user_session(users(:william_shatner))

      get user_playlist_path('sudara', 'owp')

      expect(response).to be_successful
    end
  end
end

require "rails_helper"

RSpec.describe PlaylistsController, type: :controller do
  describe "permissions" do
    it "should show a playlist" do
      get :show, params: { id: playlists(:owp).id, permalink: 'owp', user_id: 'sudara' }
      expect(response).to be_successful
    end

    it "should NOT let a not-logged person edit a playlist" do
      # not logged in
      edit_sudaras_playlist
      expect(response).not_to be_successful
      expect(response).to redirect_to('/login')
    end

    it "should not let a not-logged in user update their playlist" do
      put :update, params: { id: playlists(:owp).id, permalink: 'owp', user_id: 'sudara', title: 'new title' }
      expect(response).not_to be_successful
      expect(response).to redirect_to('/login')
    end

    %i[sort_tracks add_track remove_track attach_pic].each do |postable|
      it "should forbid any modification of playlist via #{postable} by non logged in" do
        post postable, params: { id: playlists(:owp).id, permalink: 'owp', user_id: 'sudara' }
        expect(response).not_to be_successful
        expect(response).to redirect_to('/login')
      end
    end

    it "should not mistake a playlist for belonging to a user when it doesn't" do
      login(:arthur)
      get :edit, params: { id: playlists(:owp).id, permalink: 'owp', user_id: 'sudara' }
      expect(response).not_to be_successful
    end

    it "should not let any old logged in user edit their playlist" do
      # logged in
      login(:arthur)
      edit_sudaras_playlist
      expect(response).not_to be_successful
    end

    it 'should let a user edit their own playlist' do
      login(:arthur)
      edit_arthurs_playlist
      expect(response).to be_successful
    end
  end

  context "sorting" do
    it 'should display albums to sort' do
      login(:sudara)
      get :sort, params: { user_id: 'sudara' }
      expect(response).to be_successful
    end

    it 'should allow sorting of playlists' do
      login(:sudara)
      order = playlists(:empty, :owp).map { |playlist| playlist.id.to_s }
      post(
        :sort,
        params: { user_id: 'sudara', playlist: order },
        xhr: true
      )
      expect(response).to be_successful
    end
  end

  context "deletion" do
    it "should not let a non-logged in person delete a playlist" do
      post :destroy, params: { id: playlists(:owp).id, permalink: 'owp', user_id: 'sudara' }
      expect(response).not_to be_successful
    end

    it 'should not let any old user delete a playlist' do
      login(:arthur)
      post :destroy, params: { id: playlists(:owp).id, permalink: 'owp', user_id: 'sudara' }
      expect(response).not_to be_successful
    end

    it 'should let an admin delete any playlist' do
      login(:sudara)
      expect { post :destroy, params: { id: playlists(:arthurs_playlist).id, permalink: 'arthurs-playlist', user_id: 'arthur' } }.to change(Playlist, :count).by(-1)
    end

    it 'should let a user delete their own playlist' do
      login(:arthur)
      expect { post :destroy, params: { id: playlists(:arthurs_playlist).id, permalink: 'arthurs-playlist', user_id: 'arthur' } }.to change(Playlist, :count).by(-1)
    end
  end

  context "add new pic" do
    it "should let a user upload a playlist photo" do
      login(:arthur)
      post :attach_pic, params: { id: 'arthurs-playlist', user_id: 'arthur', pic: { pic: fixture_file_upload('images/jeffdoessudara.jpg', 'image/jpeg') } }
      expect(flash[:notice]).to be_present
      expect(response).to redirect_to(edit_user_playlist_path(users(:arthur), 'arthurs-playlist'))
    end

    it "should not let a user upload a new photo for another user" do
      login(:arthur)
      post :attach_pic, params: { id: 'owp', user_id: 'sudara', pic: { pic: fixture_file_upload('images/jeffdoessudara.jpg', 'image/jpeg') } }
      expect(response).to redirect_to('/login')
    end

    it "should break the homepage cache" do
      playlist = playlists(:arthurs_playlist)
      login(:arthur)
      expect do
       post :attach_pic, params: { id: playlist.permalink, user_id: 'arthur', pic: { pic: fixture_file_upload('images/jeffdoessudara.jpg', 'image/jpeg') } }
      end.to change { playlist.reload.updated_at }
    end
  end

  describe "sharing and exporting" do
    it "should deliver us tasty xml for single playlist" do
      request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, params: { id: playlists(:owp).id, user_id: 'sudara', permalink: 'owp' }
      expect(response).to be_successful
    end
  end

  describe "someone using the old theme" do
    let(:user) { :william_shatner }

    before do
      login(user)
    end

    it "visits a public playlist" do
      get :show, params: { id: playlists(:owp).id, permalink: 'owp', user_id: 'sudara' }
      expect(response).to be_successful
    end
  end

  def edit_sudaras_playlist
    # a little ghetto, rspec won't honor string ids
    get :edit, params: { id: playlists(:owp).id, permalink: 'owp', user_id: 'sudara' }
  end

  def edit_arthurs_playlist
    get :edit, params: { id: playlists(:arthurs_playlist).id, permalink: 'arthurs-playlist', user_id: 'arthur' }
  end
end

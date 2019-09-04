require "rails_helper"

RSpec.describe AssetsController, type: :controller do
  describe "#destroy" do
    before do
      login(:sudara)
    end

    let(:asset) { assets(:asset_with_relations_for_soft_delete) }

    it "should soft_delete asset" do
      expect {
        delete :destroy, params: { user_id: asset.user.login, id: asset.id }
      }.to change(Asset, :count).by(-1)
    end

    it "should soft_delete asset's comments" do
      comment_count = asset.comments.count
      expect(comment_count).to be > 0
      expect {
        delete :destroy, params: { user_id: asset.user.login, id: asset.id }
      }.to change(Comment, :count).by(-comment_count)
    end

    it "should not touch audio_feature" do
      expect(asset.audio_feature).not_to be_nil
      expect {
        delete :destroy, params: { user_id: asset.user.login, id: asset.id }
      }.not_to change(AudioFeature, :count)
    end

    it "should soft_delete tracks" do
      tracks_count = asset.tracks.count
      expect(tracks_count).to be > 0
      expect {
        delete :destroy, params: { user_id: asset.user.login, id: asset.id }
      }.to change(Track, :count).by(-tracks_count)
    end

    it "should cleanup any existing playlists" do
      playlist = asset.tracks.first.playlist
      playlist_tracks_count = playlist.tracks_count
      # make sure there are more than 0 tracks in that playlist
      expect(playlist_tracks_count).to be >= 1

      delete :destroy, params: { user_id: asset.user.login, id: asset.id }
      # confirm it no longer shows soft_deleted tracks
      expect(playlist.reload.tracks.count).to eq(playlist_tracks_count - 1)
      # confirm it recalculated tracks_count
      expect(playlist.reload.tracks_count).to eq(playlist_tracks_count - 1)
    end


    it "should soft_delete listens" do
      listens_count = asset.listens.count
      # make sure there are more than 0 listens for that asset
      expect(listens_count).to be > 0

      expect {
        delete :destroy, params: { user_id: asset.user.login, id: asset.id }
      }.to change(Listen, :count).by(-listens_count)
    end

    it "should NOT touch users' listens_count unless we can prove that the listen was spammy" do
      user = asset.user
      user_listens_count = user.listens_count

      expect(user_listens_count).to be > 0

      delete :destroy, params: { user_id: asset.user.login, id: asset.id }
      # 2 listens in listens.yml
      expect(user.reload.listens_count).to eq(user_listens_count)
    end
  end
  context "new" do
    it 'should display limit reached flash for new users with >= 25 tracks' do
      login(:brand_new_user)
      get :new
      expect(response).to be_successful
      expect(response.body).to include('To prevent abuse, new users are limited to 25 uploads in their first day. Come back tomorrow!')
    end
  end

  it 'should disable the form for new users with >= 24 tracks' do
    login(:brand_new_user)
    get :new
    expect(assigns(:upload_disabled)).to be_present
  end

  context "#update with new file" do
    context "that's not spam" do
      before :each do
        akismet_stub_response_ham
        login(:jamie_kiesl)
      end

      let(:asset) { users(:jamie_kiesl).assets.last }
      subject {  put :update, params: { id: asset, user_id: users(:jamie_kiesl).login, asset: { mp3: fixture_file_upload('files/tag1.mp3', 'audio/mpeg') } } }

      it 'should allow user to upload new version of song' do
        post :create, params: { user_id: users(:jamie_kiesl).login, asset_data: [fixture_file_upload('files/muppets.mp3', 'audio/mpeg')] }
        expect(users(:jamie_kiesl).assets.first.mp3_file_name).to eq('muppets.mp3')
        put :update, params: { id: users(:jamie_kiesl).assets.first, user_id: users(:jamie_kiesl).login, asset: { mp3: fixture_file_upload('files/tag1.mp3', 'audio/mpeg') } }
        expect(users(:jamie_kiesl).assets.reload.first.mp3_file_name).to eq('tag1.mp3')
      end

      it 'should not change the number of listens' do
        asset = users(:jamie_kiesl).assets.last
        expect(asset.listens_count).to be > 0
        put :update, params: { id: asset, user_id: users(:jamie_kiesl).login, asset: { mp3: fixture_file_upload('files/tag1.mp3', 'audio/mpeg') } }
        expect(asset.reload.listens_count).to be > 0
      end
    end

    context "redirect" do
      let(:asset) { users(:jamie_kiesl).assets.last }
      subject { put :update, params: { id: asset, user_id: users(:jamie_kiesl).login, asset: { mp3: fixture_file_upload('files/tag1.mp3', 'audio/mpeg') } } }

      it 'should redirect back to asset page' do
        akismet_stub_response_ham
        login(:jamie_kiesl)
        expect(subject).to redirect_to('/Jamiek/tracks/mark-s-williams')
      end

      it 'should display an error if something is wrong' do
        allow_any_instance_of(Asset).to receive(:update).and_return(false)
        akismet_stub_response_ham
        login(:jamie_kiesl)
        put :update, params: { id: asset, user_id: users(:jamie_kiesl).login, asset: { foo: 'bar', mp3: fixture_file_upload('files/tag1.mp3', 'audio/mpeg') } }
        expect(response.body).to match(/There was an issue with updating that track/)
      end
    end

    context "that's spam" do
      before :each do
        akismet_stub_response_spam
        login(:jamie_kiesl)
      end

      let(:asset) { users(:jamie_kiesl).assets.last }

      it "should still allow user to upload new track" do
        put :update, params: { id: asset, user_id: users(:jamie_kiesl).login, asset: { mp3: fixture_file_upload('files/tag1.mp3', 'audio/mpeg') } }
        expect(asset.reload.mp3_file_name).to eq('tag1.mp3')
      end

      it "should mark asset as spam" do
        put :update, params: { id: asset, user_id: users(:jamie_kiesl).login, asset: { mp3: fixture_file_upload('files/tag1.mp3', 'audio/mpeg') } }
        expect(asset.reload.is_spam).to eq(true)
      end
    end
  end

  context "#radio" do
    ['those_you_follow', 'songs_you_have_not_heard', 'mangoz_shuffle'].each do |source|
      it "should raise an error if trying to access #{source} with no current user" do
        get :radio, params: { source: source }
        expect(response.status).to eq(404)
      end
    end
  end

  context "#mass_edit" do
    it 'should allow user to edit 1 track' do
      login(:arthur)
      get :mass_edit, params: { user_id: users(:arthur).login, assets: [assets(:valid_arthur_mp3).id] }
      expect(response).to be_successful
      expect(assigns(:assets)).to include(assets(:valid_arthur_mp3))
    end

    it 'should allow user to edit 2 tracks at once' do
      login(:sudara)
      two_assets = [users(:sudara).assets.first, users(:sudara).assets.last]
      get :mass_edit, params: { user_id: users(:sudara).login, assets: two_assets.collect(&:id) }
      expect(response).to be_successful
      expect(assigns(:assets)).to include(two_assets.first)
      expect(assigns(:assets)).to include(two_assets.last)
    end

    it 'should not allow user to edit other peoples tracks' do
      login(:arthur)
      get :mass_edit, params: { user_id: users(:arthur).login, assets: [assets(:valid_mp3).id] }
      expect(response).to be_successful # no wrong answer here :)
      expect(assigns(:assets)).not_to include(assets(:valid_mp3))
      expect(assigns(:assets)).to be_present # should be populated with user's own assets
    end

    it 'should not error when user accesses /mass_edit by clicking Click here to mass-edit all your tracks' do
      login(:arthur)
      get :mass_edit, params: { user_id: users(:arthur).login }
      expect(response).to be_successful
    end
  end

  context "#update" do
    before do
      login(:arthur)
    end

    it 'should allow user to update track title and description' do
      akismet_stub_response_ham
      put :update, params: { id: users(:arthur).assets.first, user_id: users(:arthur).login, asset: { description: 'normal description' } }, xhr: true
      expect(response).to be_successful
    end

    it 'should call out to rakismet on update' do
      akismet_stub_response_spam
      put :update, params: { id: users(:arthur).assets.first, user_id: users(:arthur).login, asset: { description: 'normal description' } }, xhr: true
      expect(users(:arthur).assets.first.private).to be_falsey
    end

    it 'should record track as spammy if it is spam' do
      akismet_stub_response_spam
      put :update, params: { id: users(:arthur).assets.first, user_id: users(:arthur).login, asset: { description: 'spammy description' } }, xhr: true
      expect(assigns(:asset).is_spam?).to be_truthy
    end
  end

  context "#show" do
    before :each do
      allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(false)
      login(:sudara)
    end

    it "should enqueue a CreateAudioFeature job if an asset does not have audio feature" do
      asset = assets(:valid_mp3_2)
      asset.audio_feature.delete

      get :show, params: { id: asset.id, user_id: users(:sudara).login }

      assert_enqueued_jobs(1)
    end

    it "should NOT enqueue anything if feature is present" do
      asset = assets(:valid_mp3)

      get :show, params: { id: asset.id, user_id: users(:sudara).login }

      assert_enqueued_jobs(0)
    end

    it "should NOT enqueue anything if is_a_bot?" do
      allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(true)

      asset = assets(:valid_mp3)

      get :show, params: { id: asset.id, user_id: users(:sudara).login }

      assert_enqueued_jobs(0)
    end
  end

  context "index" do
    before :each do
      login(:sudara)
    end

    it "should render index_white template" do
      get :index, params: { user_id: users(:sudara).login }
      expect(response.status).to eq(200)
      expect(response).to render_template(:index_white)
      expect(response.content_type).to eq("text/html; charset=utf-8")
    end

    it "should display user's track if it is hot" do
      assets(:valid_mp3).update(hotness: 2)

      get :index, params: { user_id: users(:sudara).login }
      expect(response.body).to match(/Hot Tracks this week/)
      expect(response.body).to match(/Very good song/)
    end

    it "displays a custom message if user doesnt have tracks yet" do
      get :index, params: { user_id: users(:joeblow).login }
      expect(response.body).to match(/Looks like joeblow hasn't uploaded anything yet!/)
    end
  end
end

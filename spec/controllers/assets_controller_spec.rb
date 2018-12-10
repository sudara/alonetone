require "rails_helper"
include ActiveJob::TestHelper

RSpec.describe AssetsController, type: :controller do
  render_views
  fixtures :assets, :users, :audio_features

  before :each do
    clear_enqueued_jobs
    clear_performed_jobs
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

  context "edit" do
    it 'should allow user to upload new version of song' do
      login(:sudara)
      post :create, params: { user_id: users(:sudara).login, asset_data: [fixture_file_upload('assets/muppets.mp3', 'audio/mpeg')] }
      expect(users(:sudara).assets.first.mp3_file_name).to eq('muppets.mp3')
      put :update, params: { id: users(:sudara).assets.first, user_id: users(:sudara).login, asset: { mp3: fixture_file_upload('assets/tag1.mp3', 'audio/mpeg') } }
      expect(users(:sudara).assets.reload.first.mp3_file_name).to eq('tag1.mp3')
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
      put :update, params: { id: users(:arthur).assets.first, user_id: users(:arthur).login, asset: { description: 'normal description' } }, xhr: true
      expect(response).to be_successful
    end

    it 'should call out to rakismet on update' do
      allow(Rakismet).to receive(:akismet_call).and_return('false')
      put :update, params: { id: users(:arthur).assets.first, user_id: users(:arthur).login, asset: { description: 'normal description' } }, xhr: true
      expect(users(:arthur).assets.first.private).to be_falsey
    end

    it 'should record track as spammy if it is spam' do
      allow(Rakismet).to receive(:akismet_call).and_return('true')
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
end

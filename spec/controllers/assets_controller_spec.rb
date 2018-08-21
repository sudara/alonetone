require "rails_helper"

RSpec.describe AssetsController, type: :controller do
  render_views
  fixtures :assets, :users
  include ActiveJob::TestHelper

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

    it 'should force a track to be private if it is spam' do
      allow(Rakismet).to receive(:akismet_call).and_return('true')
      put :update, params: { id: users(:arthur).assets.first, user_id: users(:arthur).login, asset: { description: 'spammy description' } }, xhr: true
      expect(assigns(:asset).private).to be_truthy
    end
  end
end

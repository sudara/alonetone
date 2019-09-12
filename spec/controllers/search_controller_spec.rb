require "rails_helper"

RSpec.describe SearchController, type: :controller do
  context "basics" do
    it 'should search assets by name / filename and return results' do
      get :index, params: { query: 'Song1' }
      expect(response).to be_successful
      expect(assigns(:assets)).to include(assets(:valid_mp3))
    end

    it 'should not return results when search term is empty' do
      get :index
      expect(response).to be_successful
      expect(flash[:error]).to be_present
      expect(assigns(:assets)).not_to be_present
    end

    it 'should not return results for asset with deleted soft_deleted user' do
      asset = assets(:valid_asset_to_test_spam_on_latest)
      get :index, params: { query: "#{asset.title}" }
      expect(assigns(:assets)).to include(assets(:valid_asset_to_test_spam_on_latest))

      asset.user.soft_delete
      get :index, params: { query: "#{asset.title}" }
      expect(assigns(:assets)).not_to be_present
    end
  end
end

require "rails_helper"

RSpec.describe FavoritesController, type: :request do
  before do
    create_user_session(users(:jamie_kiesl))
  end

  let(:asset) { assets(:valid_mp3) }
  let(:user) { users(:jamie_kiesl) }

  describe '#destroy' do
    before :each do
      user.tracks.favorites.create(asset_id: asset.id)
    end

    it "should destroy track" do
      expect do
        delete "/#{user.login}/favorites/#{Track.last.id}"
      end.to change { Track.count }.by(-1)
    end

    it "should decrement favorites_count" do
      expect {
        delete "/#{user.login}/favorites/#{Track.last.id}"
      }.to change{ asset.reload.favorites_count }.by(-1)
    end
  end

  describe '#create' do
    it "should create a new track" do
      expect do
        post "/#{user.login}/favorites", params: { asset_id: asset.id }
      end.to change { Track.count }.by(1)
    end

    it "should create a favorites track" do
      post "/#{user.login}/favorites", params: { asset_id: asset.id }
      expect(Track.last.is_favorite).to eq(true)
    end

    it "should increase asset's favorites_count" do
      expect do
        post "/#{user.login}/favorites", params: { asset_id: asset.id }
      end.to change{ asset.reload.favorites_count }.by(1)
    end

    it "should return false if asset not found" do
      asset.delete

      expect do
        post "/#{user.login}/favorites", params: { asset_id: asset.id }
      end.to raise_error(ArgumentError)
    end
  end
end
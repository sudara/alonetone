require "rails_helper"

RSpec.describe ListensController, type: :controller do
  describe "#index" do
    it "uses separate page keys for listened tracks and track plays" do
      get :index, params: { login: 'arthur' }

      expect(response).to be_successful
      expect(assigns(:listens_pagy).options[:page_key]).to eq('listens_page')
      expect(assigns(:track_plays_pagy).options[:page_key]).to eq('track_plays_page')
    end
  end
end

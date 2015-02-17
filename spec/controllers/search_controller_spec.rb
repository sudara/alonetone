require "rails_helper"

RSpec.describe SearchController, type: :controller do

  fixtures :users, :assets

  context "basics" do
    it 'should search assets by name / filename and return results' do
      get :index, :query => 'Song1'
      expect(response).to be_success
      expect(assigns(:assets)).to include(assets(:valid_mp3))
    end

    it 'should not return results when search term is empty' do
      get :index
      expect(response).to be_success
      expect(flash[:error]).to be_present
      expect(assigns(:assets)).not_to be_present
    end
  end

end

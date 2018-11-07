require "rails_helper"

RSpec.describe FollowingController, type: :controller do
  fixtures :users

  context 'follow' do
    it 'should increment following count by one' do
      login(:brand_new_user)
      get :follow, params: { login: 'sudara' }
      expect(users(:brand_new_user).follows.count).to eq(1)
    end

    it 'should not let you follow someone twice' do
      login(:brand_new_user)
      get :follow, params: { login: 'sudara' }
      get :follow, params: { login: 'sudara' }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to be_present
    end
  end

  context 'unfollow' do
    it 'should decrement following count by one' do
      login(:brand_new_user)
      get :unfollow, params: { login: 'sudara' }
      expect(users(:brand_new_user).follows.count).to eq(0)
    end

    it 'should not let you unfollow someone you do not already follow' do
      login(:brand_new_user)
      get :unfollow, params: { login: 'sudara' }
      get :unfollow, params: { login: 'sudara' }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to be_present
    end
  end
end

require "rails_helper"

RSpec.describe NotificationsController, type: :controller do
  fixtures :users

  context 'subscribe' do
    it 'should mark email_new_tracks setting as true' do
      login(:brand_new_user)
      get :subscribe
      expect(users(:brand_new_user).settings[:email_new_tracks]).to eq(true)
    end
  end

  context 'unsubscribe' do
    it 'should mark email_new_tracks setting as false' do
      login(:brand_new_user)
      get :unsubscribe
      expect(users(:brand_new_user).settings[:email_new_tracks]).to eq(false)
    end
  end
end

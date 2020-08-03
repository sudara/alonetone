require "rails_helper"

RSpec.describe NotificationsController, type: :controller do
  let(:user) { users(:brand_new_user) }

  before do
    login(user)
  end

  context 'unsubscribe' do
    it 'should mark email_new_tracks setting as false' do
      get :unsubscribe
      expect(user.settings.email_new_tracks).to eq(false)
    end
  end

  context 'subscribe' do
    it 'should mark email_new_tracks setting as true' do
      # this is the default
      get :unsubscribe
      get :subscribe
      expect(user.settings.email_new_tracks?).to eq(true)
    end
  end
end

require "rails_helper"

RSpec.describe NotificationsController, type: :request do
  let(:user) { users(:brand_new_user) }

  before do
    create_user_session(user)
  end

  it "marks email_new_tracks setting as false when unsubscribing" do
    get "/notifications/unsubscribe"

    expect(response).to redirect_to(root_path)
    expect(user.settings.reload.email_new_tracks).to eq(false)
  end

  it "marks email_new_tracks setting as true when subscribing" do
    get "/notifications/unsubscribe"
    get "/notifications/subscribe"

    expect(response).to redirect_to(root_path)
    expect(user.settings.reload.email_new_tracks?).to eq(true)
  end
end

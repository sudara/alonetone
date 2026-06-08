require "rails_helper"

RSpec.describe FollowingController, type: :request do
  before :each do
    create_user_session(users(:brand_new_user))
  end

  it "should successfully follow someone" do
    expect { get "/follow/sudara" }.to change { users(:brand_new_user).follows.count }.by(1)
    follow_redirect!
    expect(response).to be_successful
  end

  it "should successfully unfollow someone", following: true do
    get "/follow/sudara"
    follow_redirect!

    get "/unfollow/sudara"
    follow_redirect!
    expect(response).to be_successful
  end

  it "should not follow someone twice" do
    get "/follow/sudara"
    follow_redirect!

    get "/follow/sudara"
    expect(response).to redirect_to(root_path)
    expect(flash[:error]).to be_present
    follow_redirect!
    expect(response).to be_successful
  end

  it "should not unfollow someone you are not already following" do
    get "/unfollow/sudara"
    expect(response).to redirect_to(root_path)
    expect(flash[:error]).to be_present
    follow_redirect!
    expect(response).to be_successful
  end
end

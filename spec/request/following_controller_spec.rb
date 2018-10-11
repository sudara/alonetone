require "rails_helper"

RSpec.describe FollowingController, type: :request do
  fixtures :users

  before :each do
    create_user_session(users(:brand_new_user))
  end

  it "should successfully follow someone" do
    get "/follow/sudara"
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
    follow_redirect!
    expect(response).to be_successful
  end

  it "should not unfollow someone you are not already following" do
    get "/follow/arthur"
    follow_redirect!
    expect(response).to be_successful
  end
end

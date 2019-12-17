require "rails_helper"

RSpec.describe "Thredded", type: :request do
  it "loads the thredded index" do
    get "/forums"
    expect(response).to be_successful
  end

  it "loads the thredded index when logged in" do
    create_user_session(users(:arthur))

    get "/forums"
    expect(response).to be_successful
  end
end

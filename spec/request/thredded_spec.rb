require "rails_helper"
RSpec.describe "Thredded", :type => :request do

  it "loads the thredded index" do
    get "/discuss"
    expect(response).to be_success
  end

  it "loads the thredded index when logged in" do
    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'test'} }
    get "/discuss"
    expect(response).to be_success
  end
end
require "rails_helper"

RSpec.describe ForumsController, type: :controller do
  fixtures :users

  it "should render index without errors" do
    get :index
    expect(response).to be_success
  end

  it "should render index without errors for user" do
    login(:arthur)
    get :index
    expect(response).to be_success
  end

end

require "rails_helper"

RSpec.describe PagesController, type: :controller do

  it "should have an about page that renders without errors" do
    get :about
    expect(response).to be_successful
  end

  it "should have a stats page that renders without errors" do
    get :stats
    expect(response).to be_successful
  end

  it "should have a contact page that renders without errors" do
    get :press
    expect(response).to be_successful
  end

end

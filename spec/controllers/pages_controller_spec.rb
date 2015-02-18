require "rails_helper"

RSpec.describe PagesController, type: :controller do

  it "should have an about page that renders without errors" do
    get :index
    expect(response).to be_success
  end

end

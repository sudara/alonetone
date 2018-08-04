require "rails_helper"
RSpec.describe "Thredded", :type => :request do

  it "loads the thredded index" do
    get "/discuss"
    expect(response).to be_success
  end
end
require "rails_helper"

RSpec.describe Update, type: :model do
  fixtures :updates

  before(:each) do
    #@update = Update.new
  end

  it "should be valid and saveable" do
    expect(updates(:valid)).to be_valid
    expect(updates(:valid).save).to eq(true)
  end
end

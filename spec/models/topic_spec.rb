require "rails_helper"

RSpec.describe Topic, type: :model do
  fixtures :forums, :topics, :posts

  context "validation" do
    it "should be valid" do
      expect(topics(:topic1)).to be_valid
    end
  end

  context "relationships" do
    it "should reach its forum" do
      expect(topics(:topic1).forum).to be_present
    end
  end
end

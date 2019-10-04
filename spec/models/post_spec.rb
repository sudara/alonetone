require "rails_helper"

RSpec.describe Post, type: :model do
  describe 'scopes' do
    it 'include user avatars to prevent n+1 queries' do
      expect do
        Post.with_preloads.each do |post|
          post.user.avatar_image
        end
      end.to perform_queries(count: 3)
    end
  end

  context "validation" do
    it "should be valid" do
      expect(posts(:post1)).to be_valid
    end
  end

  context "relationships" do
    it "should reach its topic" do
      expect(posts(:post1).topic).to be_present
    end

    it "should reach its forum" do
      expect(posts(:post1).forum).to be_present
    end
  end
end

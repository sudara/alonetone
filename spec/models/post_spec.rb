# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  topic_id   :integer
#  body       :text(65535)
#  created_at :datetime
#  updated_at :datetime
#  forum_id   :integer
#  body_html  :text(65535)
#  is_spam    :boolean          default(FALSE)
#  spaminess  :float(24)
#  signature  :string(255)
#

require "rails_helper"

RSpec.describe Post, type: :model do
  fixtures :forums, :topics, :posts, :users

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

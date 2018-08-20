# == Schema Information
#
# Table name: topics
#
#  id              :integer          not null, primary key
#  forum_id        :integer
#  user_id         :integer
#  title           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  hits            :integer          default(0)
#  sticky          :integer          default(0)
#  posts_count     :integer          default(0)
#  locked          :boolean          default(FALSE)
#  last_post_id    :integer
#  last_updated_at :datetime
#  last_user_id    :integer
#  site_id         :integer
#  permalink       :string(255)
#  spam            :boolean          default(FALSE)
#  spaminess       :float(24)
#  signature       :string(255)
#

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

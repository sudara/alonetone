require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:new_comment) { assets(:valid_mp3).comments.new(body: 'test') }
  let(:asset) { comments(:valid_comment_on_asset_by_user).commentable }

  context "validation" do
    it "should be valid when made by user" do
      expect(comments(:valid_comment_on_asset_by_user)).to be_valid
    end

    it "should be valid when made by guest" do
      expect(comments(:valid_comment_on_asset_by_guest)).to be_valid
    end

    it "should be valid even if spam" do
      expect(comments(:spam_comment_on_asset_by_guest)).to be_valid
    end

    it "should be able to be private as user" do
      expect(comments(:private_comment_on_asset_by_user)).to be_valid
    end

    it "should be able to be private as guest" do
      expect(comments(:private_comment_on_asset_by_guest)).to be_valid
    end
  end

  context "saving" do
    it "should store user_id when commenting on an asset" do
      expect(new_comment.save).to be_truthy
      expect(new_comment.user_id).to eq(assets(:valid_mp3).user_id)
    end

    it "should not allow a dupe within an hour (same content/ip)" do
      body = comments(:valid_comment_on_asset_by_user).body
      ip = comments(:valid_comment_on_asset_by_user).remote_ip
      comment1 = asset.comments.create(body: body, remote_ip: ip)
      comment2 = asset.comments.new(body: body, remote_ip: ip)
      expect(comment2.save).to be_falsey
    end

    it "should allow duplicates after an hour" do
      body = comments(:valid_comment_on_asset_by_user).body
      ip = comments(:valid_comment_on_asset_by_user).remote_ip
      comment1 = asset.comments.create(body: body, remote_ip: ip)
      travel_to(2.hours.from_now) do
        comment2 = asset.comments.new(body: body, remote_ip: ip)
        expect(comment2.save).to be_truthy
      end
    end

    it "should not consider two different single emoji duplicates" do
      ip = comments(:valid_comment_on_asset_by_user).remote_ip
      comment1 = asset.comments.create(body: "🤑", remote_ip: ip)
      comment2 = asset.comments.new(body: "💀", remote_ip: ip)
      expect(comment2.save).to be_truthy
    end
  end

  describe "soft deletion" do
    it "only soft deletes" do
      expect do
        Comment.all.map(&:soft_delete)
      end.not_to change { Comment.unscoped.count }
    end

    it "changes scope" do
      original_count = Comment.count
      expect do
        Comment.all.map(&:soft_delete)
      end.to change { Comment.count }.from(original_count).to(0)
    end
  end

  describe "to_other_members scope" do
    describe "included comments" do
      before do
        users(:jamie_kiesl).update_attribute("current_login_ip", "127.1.1.12")
      end
      it "should include comments by users to each other" do
        expect(Comment.all.to_other_members).to include(comments(:public_non_spam_comment_to_another_user))
      end
    end

    describe "not included comments" do
      before do
        users(:jamie_kiesl).update_attribute("current_login_ip", "127.1.1.2")
      end

      it "should not include comments made by user on its own track" do
        expect(Comment.all.to_other_members).not_to include(comments(:public_non_spam_comment_to_self))
      end

      it "should not include a comment made by matching ip address" do
        expect(Comment.all.to_other_members).not_to include(comments(:public_non_spam_comment_to_self_by_ip))
      end
    end
  end
end

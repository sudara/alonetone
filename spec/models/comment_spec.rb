require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:new_comment) { assets(:valid_mp3).comments.new(body: 'test') }
  let(:asset) { comments(:valid_comment_on_asset_by_user).commentable }

  describe 'scopes' do
    it 'include avatar image for comments and commenter to prevent n+1 queries' do
      expect do
        Comment.with_preloads.each do |comment|
          comment.commenter&.avatar_image
          if commentable = comment.commentable
            commentable.user.avatar_image
          end
        end
      end.to perform_queries(count: 6)
    end
  end

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

  context "spam_if_banned_words!" do
    it "inspects the body for banned words and marks as spam" do
      akismet_stub_response_ham # it fails to detect
      akismet_stub_submit_spam
      new_comment.body = "This is a comment with a banned word: sex https"
      new_comment.spam_if_banned_words!
      expect(new_comment).to be_spam
    end

    it "does not mark as spam with just one banned word" do
      akismet_stub_response_ham
      akismet_stub_submit_spam
      new_comment.body = "This is a comment with a banned word: https"
      new_comment.spam_if_banned_words!
      expect(new_comment).not_to be_spam
    end

    it "does not mark as spam with no banned words" do
      akismet_stub_response_ham
      new_comment.body = "This is a comment with no banned words"
      new_comment.spam_if_banned_words!
      expect(new_comment).not_to be_spam
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

  describe 'cached comment counts' do
    let(:counted_asset) { assets(:valid_mp3) }
    let(:receiver) { counted_asset.user }

    it 'increments on create and decrements when a live comment is destroyed' do
      comment = nil
      expect { comment = Comment.create!(commentable: counted_asset, commenter: users(:arthur), body: 'nice one') }
        .to change { counted_asset.reload.comments_count }.by(1)
        .and change { receiver.reload.comments_count }.by(1)

      expect { comment.destroy }
        .to change { counted_asset.reload.comments_count }.by(-1)
        .and change { receiver.reload.comments_count }.by(-1)
    end

    it 'leaves counts untouched for spam comments' do
      comment = Comment.create!(commentable: counted_asset, commenter: users(:arthur), body: 'spammy', is_spam: true)
      expect { comment.destroy }.not_to change { counted_asset.reload.comments_count }
    end

    it 'does not decrement again when destroying an already soft-deleted comment' do
      comment = Comment.create!(commentable: counted_asset, commenter: users(:arthur), body: 'nice one')
      comment.update_columns(deleted_at: 1.hour.ago)

      expect { comment.destroy }.not_to change { counted_asset.reload.comments_count }
    end

    it 'recomputes drifted counts from the live, non-spam comments' do
      Comment.create!(commentable: counted_asset, commenter: users(:arthur), body: 'counts')
      Comment.create!(commentable: counted_asset, commenter: users(:arthur), body: 'spam, ignored', is_spam: true)
      expected_asset = counted_asset.comments.where(is_spam: false).count
      expected_receiver = Comment.where(user_id: receiver.id, is_spam: false, commentable_type: 'Asset').count

      counted_asset.update_columns(comments_count: 999)
      receiver.update_columns(comments_count: 999)

      Comment.recompute_cached_counts!

      expect(counted_asset.reload.comments_count).to eq(expected_asset)
      expect(receiver.reload.comments_count).to eq(expected_receiver)
    end
  end
end

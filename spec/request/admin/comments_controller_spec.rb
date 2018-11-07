require 'rails_helper'
# 
RSpec.describe Admin::CommentsController, type: :request do
  fixtures :comments, :users

  before do
    create_user_session(users(:sudara))
  end

  describe "for individual comments" do
    let(:comment) { comments(:valid_comment_on_asset_by_guest) }

    it "should mark comments as spam" do
      expect(comment.is_spam).to eq(false)
      put "/admin/comments/#{comment.id}/spam"
      comment.reload
      expect(comment.is_spam).to eq(true)
    end

    it "should update RAKISMET" do
      expect(Rakismet).to receive(:akismet_call)
      put spam_admin_comment_path(comment.id)
    end
  end

  describe "for user" do
    let(:user) { users(:arthur) }

    let(:comment1) { comments(:private_comment_on_asset_by_user) }
    let(:comment2) { comments(:public_spam_comment_on_asset_by_user) }
    let(:comment3) { comments(:public_comment_on_asset_by_user) }

    it "should mark all comments as spam" do
      put spam_group_admin_comments_path, params: { mark_spam_by: { user_id: user.id }}

      expect(comment1.is_spam).to eq(true)
      expect(comment2.is_spam).to eq(true)
      expect(comment3.is_spam).to eq(true)
    end

    it "should update RAKISMET only for spam tracks" do
      expect(Rakismet).to receive(:akismet_call).twice
      put spam_group_admin_comments_path, params: { mark_spam_by: { user_id: user.id }}
    end
  end
end

require 'rails_helper'

RSpec.describe Admin::CommentsController, type: :request do
  before do
    create_user_session(users(:sudara))
  end

  describe "spam for individual comments" do
    let(:comment) { comments(:valid_comment_on_asset_by_guest) }

    it "should mark comments as spam" do
      akismet_stub_submit_spam
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

  describe "unspam individual comments" do
    # asset id 1 is needed for comment's commentable to return true
    # for is_deliverable?
    let!(:asset) { assets(:valid_mp3) }
    let(:comment) { comments(:public_spam_comment_on_asset_by_user) }

    it "should unspam the comment" do
      akismet_stub_submit_ham
      put unspam_admin_comment_path(comment.id)
      expect(comment.reload.is_spam).to eq(false)
    end

    it "should update RAKISMET" do
      expect(Rakismet).to receive(:akismet_call)
      put unspam_admin_comment_path(comment.id)
    end

    it "should send notification" do
      akismet_stub_submit_ham
      expect do
        put unspam_admin_comment_path(comment.id)
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end

  describe "mass spam update" do
    let(:comment1) { comments(:private_comment_on_asset_by_user) }
    let(:comment2) { comments(:public_spam_comment_on_asset_by_user) }
    let(:comment3) { comments(:public_comment_on_asset_by_user) }

    it "should mark all comments as spam" do
      akismet_stub_submit_spam

      put mark_group_as_spam_admin_comments_path, params: { mark_spam_by: { remote_ip: '127.0.0.2' } }

      expect(comment1.is_spam).to eq(true)
      expect(comment2.is_spam).to eq(true)
      expect(comment3.is_spam).to eq(true)
    end

    it "should update RAKISMET only for spam tracks" do
      expect(Rakismet).to receive(:akismet_call).twice
      put mark_group_as_spam_admin_comments_path, params: { mark_spam_by: { remote_ip: '127.0.0.2' } }
    end

    it "should alow mass update by other attributes (like user_id)" do
      akismet_stub_submit_spam

      put mark_group_as_spam_admin_comments_path, params: { mark_spam_by: { user_id: comment1.user_id } }
      expect(comment1.reload.is_spam).to eq(true)
      expect(comment3.reload.is_spam).to eq(true)
    end
  end
end

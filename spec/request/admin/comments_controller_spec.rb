require 'rails_helper'

RSpec.describe Admin::CommentsController, type: :request do
  fixtures :comments, :users

  before do
    create_user_session(users(:sudara))
  end

  describe "spam for individual comments" do
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

  describe "unspam individual comments" do
    let(:comment) { comments(:public_spam_comment_on_asset_by_user) }

    it "should unspam the comment" do
      put unspam_admin_comment_path(comment.id)
      expect(comment.reload.is_spam).to eq(false)
    end

    it "should update RAKISMET" do
      expect(Rakismet).to receive(:akismet_call)
      put unspam_admin_comment_path(comment.id)
    end

    it "should send notification" do
      allow(comment).to receive(:is_deliverable?).and_return(true)

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
      put mark_group_as_spam_admin_comments_path, params: { mark_spam_by: { user_id: comment1.user_id } }
      expect(comment1.reload.is_spam).to eq(true)
      expect(comment3.reload.is_spam).to eq(true)
    end
  end
end

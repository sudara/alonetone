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

    it "should render a turbo_stream replacing the comment row" do
      akismet_stub_submit_spam
      put spam_admin_comment_path(comment.id), as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(%(action="replace"))
      expect(response.body).to include(%(target="comment_#{comment.id}"))
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

    it "should render a turbo_stream replacing the comment row" do
      akismet_stub_submit_ham
      put unspam_admin_comment_path(comment.id), as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(%(action="replace"))
      expect(response.body).to include(%(target="comment_#{comment.id}"))
    end
  end

  describe "#index" do
    it "mutes spam rows without a danger border" do
      comment = comments(:public_spam_comment_on_asset_by_user)

      get admin_comments_path

      doc = Nokogiri::HTML(response.body)
      row = doc.at_css("#comment_#{comment.id}")
      expect(row['class']).not_to include('border-danger')
      expect(row.at_css('.opacity-70')).to be_present
      expect(row.text).to include('spam')
    end
  end
end

require 'rails_helper'

RSpec.describe CommentsController, type: :request do
  before do
    akismet_stub_response_ham
  end

  context "spamming" do
    let!(:asset) { assets(:valid_mp3) }

    it "should mark as spam if body contains multiple banned words" do
      akismet_stub_submit_ham
      akismet_stub_submit_spam
      params = { :comment => { "body" => "https sex", "private" => "0", "commentable_type" => "Asset", "commentable_id" => asset.id }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      expect do
        post(
          "/comments",
          params: params,
          headers: {
            'x-forwarded-for' => '8.8.8.8',
            'user-agent' => 'webkit'
          }
        )
      end.to change(Comment, :count)
      puts Comment.last.inspect
      expect(Comment.last.is_spam).to be true
    end

    it "should allow one banned word" do
      akismet_stub_response_ham
      akismet_stub_submit_spam
      params = { :comment => { "body" => "https", "private" => "0", "commentable_type" => "Asset", "commentable_id" => asset.id }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      expect do
        post(
          "/comments",
          params: params,
          headers: {
            'x-forwarded-for' => '8.8.8.8',
            'user-agent' => 'webkit'
          }
        )
      end.to change(Comment, :count)
      puts Comment.last.inspect
      expect(Comment.last.is_spam).to be false
    end
  end

  context "guest rate limiting" do
    let!(:asset) { assets(:valid_mp3) }

    it "should allow a guest to comment" do
      params = { :comment => { "body" => "Comment", "private" => "0", "commentable_type" => "Asset", "commentable_id" => asset.id }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      expect do
        post(
          "/comments",
          params: params,
          headers: {
            'x-forwarded-for' => '8.8.8.8',
            'user-agent' => 'webkit'
          }
        )
      end.to change(Comment, :count)
      expect(response).to have_http_status(201)
    end

    it "should not allow a guest to comment more than 5 times in 24 hours" do
      params = { :comment => { "body" => "Rate Limited Yall", "private" => "0", "commentable_type" => "Asset", "commentable_id" => asset.id }, "track_id" => assets(:valid_mp3).permalink }
      5.times do |i|
        params[:comment][:body] = "Comment rate limit num #{i}"
        expect do
          post(
            "/comments",
            params: params,
            headers: {
              'x-forwarded-for' => '8.8.8.8',
              'user-agent' => 'webkit'
            }
          )
        end.to change(Comment, :count)
        expect(Comment.last.remote_ip).to eql('8.8.8.8')
        expect(response).to have_http_status(201)
      end
      expect do
        params[:comment][:body] = "Comment rate limit num 6"
        post(
          "/comments",
          params: params,
          headers: {
            'x-forwarded-for' => '8.8.8.8',
            'user-agent' => 'webkit'
          }
        )
      end.not_to change(Comment, :count)
      expect(response).not_to be_successful
    end
  end

  context "deleting" do
    it "is not possible by a guest" do
      comment = comments(:public_comment_on_asset_by_user)
      delete(comment_path(comment))
      expect(response).to redirect_to('/login')
    end

    it "by the comment recepient" do
      create_user_session(users(:arthur))
      comment = comments(:public_comment_on_asset_by_user)
      delete(comment_path(comment))
      expect(response).to have_http_status(303)
    end
  end

  context "marking a comment as spam" do
    it "is not possible by a guest" do
      akismet_stub_submit_spam
      comment = comments(:public_comment_on_asset_by_user)
      put spam_user_track_comment_path(users(:arthur), comment.commentable, comment)

      expect(response).to redirect_to('/login')
      expect(Comment.find(comment.id).is_spam).to be false
    end

    it "is possible by the comment recepient if it's a user comment" do
      akismet_stub_submit_spam
      create_user_session(users(:arthur))
      comment = comments(:public_comment_on_asset_by_user)
      put spam_user_track_comment_path(users(:arthur), comment.commentable, comment)
      expect(response).to have_http_status(303)
      expect(Comment.find(comment.id).is_spam).to be true
      expect(flash[:ok]).to eq('We marked that comment as spam')
    end

    it "is possible by the comment recepient if it's a guest comment" do
      akismet_stub_submit_spam
      create_user_session(users(:arthur))
      comment = comments(:public_comment_on_asset_by_guest)
      expect(comment.valid?).to be true
      put spam_user_track_comment_path(users(:arthur), comment.commentable, comment)
      expect(response).to have_http_status(303)
      expect(Comment.with_deleted.find(comment.id).is_spam).to be true
      expect(flash[:ok]).to eq('We marked that comment as spam')
    end
  end

  context "unspamming a comment" do
    it "is not possible by a guest" do
      akismet_stub_submit_ham
      comment = comments(:public_comment_on_asset_by_user)
      put unspam_user_track_comment_path(users(:arthur), comment.commentable, comment)

      expect(response).to redirect_to('/login')
      expect(Comment.find(comment.id).is_spam).to be false
    end

    it "is possible by the comment recepient if it's a user comment" do
      akismet_stub_submit_ham
      akismet_stub_submit_spam
      create_user_session(users(:arthur))
      comment = comments(:public_comment_on_asset_by_user)
      comment.spam! # make it spam first
      comment.is_spam = true
      put unspam_user_track_comment_path(users(:arthur), comment.commentable, comment)
      expect(response).to have_http_status(303)
      expect(Comment.find(comment.id).is_spam).to be false
      expect(flash[:ok]).to eq('We un-spammed and made that comment public')
    end

    it "is possible by the comment recepient if it's a guest comment" do
      akismet_stub_submit_ham
      akismet_stub_submit_spam
      create_user_session(users(:arthur))
      comment = comments(:public_comment_on_asset_by_guest)
      comment.spam! # make it spam first
      comment.is_spam = true
      put unspam_user_track_comment_path(users(:arthur), comment.commentable, comment)
      expect(response).to have_http_status(303)
      expect(Comment.with_deleted.find(comment.id).is_spam).to be false
      expect(flash[:ok]).to eq('We un-spammed and made that comment public')
    end
  end
end

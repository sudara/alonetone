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
      end.to change(Comment.with_deleted, :count)
      expect(Comment.with_deleted.last.is_spam).to be true
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
      expect(Comment.last.is_spam).to be false
    end
  end

  context "when Akismet flags a comment" do
    let!(:asset) { assets(:valid_mp3) }

    it "still saves it but marks is_spam (so it's hidden from public views)" do
      akismet_stub_response_spam
      akismet_stub_submit_spam
      params = { comment: { body: "anything", private: "0", commentable_type: "Asset", commentable_id: asset.id } }
      expect do
        post "/comments", params: params, headers: { 'x-forwarded-for' => '8.8.8.8', 'user-agent' => 'webkit' }
      end.to change(Comment.with_deleted, :count).by(1)
      expect(response).to have_http_status(201)
      expect(Comment.with_deleted.last.is_spam).to be true
      expect(Comment.with_deleted.last.soft_deleted?).to be true
    end
  end

  context "when Rakismet is not configured (no key, e.g. dev with key commented out)" do
    let!(:asset) { assets(:valid_mp3) }

    before { allow(Rakismet).to receive(:key).and_return(nil) }

    it "saves the comment as ham without calling Akismet" do
      params = { comment: { body: "hi", private: "0", commentable_type: "Asset", commentable_id: asset.id } }
      expect do
        post "/comments", params: params, headers: { 'x-forwarded-for' => '8.8.8.8', 'user-agent' => 'webkit' }
      end.to change(Comment, :count).by(1)
      expect(response).to have_http_status(201)
      expect(Comment.last.is_spam).to be false
      expect(a_request(:post, /akismet/i)).not_to have_been_made
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

  context "basics" do
    let(:asset) { assets(:valid_mp3) }
    let(:params) do
      {
        comment: {
          body: "Comment",
          private: "0",
          commentable_type: "Asset",
          commentable_id: asset.id
        },
        user_id: users(:sudara).login,
        track_id: asset.permalink
      }
    end

    it "allows anyone to view the comments index" do
      get "/comments"

      expect(response).to be_successful
      expect(response.body).to include("Recent Comments")
    end

    it "allows a guest to comment on a track" do
      expect do
        post "/comments", params: params, headers: { 'X-Requested-With' => 'XMLHttpRequest' }
      end.to change { Comment.count }.by(1)
      expect(response).to be_successful
    end

    it "allows a user to comment on a track" do
      create_user_session(users(:arthur))

      post "/comments", params: params, headers: { 'X-Requested-With' => 'XMLHttpRequest' }

      expect(response).to be_successful
    end

    it "allows a private comment on a track" do
      create_user_session(users(:arthur))

      post "/comments",
        params: params.deep_merge(comment: { private: "1" }),
        headers: { 'X-Requested-With' => 'XMLHttpRequest' }

      expect(response).to be_successful
      expect(Comment.last).to be_private
    end
  end

  context "spam handling" do
    it "sends email to track owner if comment was not spam" do
      create_user_session(users(:sudara))
      params = {
        comment: {
          body: "Comment yo!",
          commentable_type: "Asset",
          commentable_id: assets(:valid_arthur_mp3).id
        },
        user_id: users(:sudara).login,
        track_id: assets(:valid_mp3).permalink
      }

      expect do
        post "/comments", params: params, headers: { 'X-Requested-With' => 'XMLHttpRequest' }
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it "does not email track owner if comment is spam" do
      create_user_session(users(:arthur))
      akismet_stub_response_spam
      params = {
        comment: {
          body: "viagra-test-123",
          private: "1",
          commentable_type: "Asset",
          commentable_id: assets(:valid_arthur_mp3).id
        },
        user_id: users(:sudara).login,
        track_id: assets(:valid_mp3).permalink
      }

      expect do
        post "/comments", params: params, headers: { 'X-Requested-With' => 'XMLHttpRequest' }
      end.not_to change { ActionMailer::Base.deliveries.size }
    end

    it "increments comment_count if comment was not spam" do
      asset = assets(:valid_mp3)
      params = {
        comment: {
          body: "Comment",
          private: "0",
          commentable_type: "Asset",
          commentable_id: asset.id
        },
        user_id: users(:sudara).login,
        track_id: asset.permalink
      }

      expect do
        post "/comments", params: params, headers: { 'X-Requested-With' => 'XMLHttpRequest' }
      end.to change { asset.reload.comments_count }.by(1)
    end

    it "does not increment comment_count if comment is spam" do
      asset = assets(:valid_arthur_mp3)
      akismet_stub_response_spam
      params = {
        comment: {
          body: "viagra-test-123",
          private: "1",
          commentable_type: "Asset",
          commentable_id: asset.id
        },
        user_id: users(:sudara).login,
        track_id: assets(:valid_mp3).permalink
      }

      post "/comments", params: params, headers: { 'X-Requested-With' => 'XMLHttpRequest' }

      expect(asset.reload.comments_count).to eq(0)
    end
  end

  context "private comments made by user" do
    let(:comment) { comments(:private_comment_on_asset_by_user) }

    it "uses a separate page key for comments made pagination" do
      create_user_session(users(:sudara))
      21.times do |i|
        Comment.create!(
          commentable: assets(:valid_arthur_mp3),
          user: users(:arthur),
          commenter: users(:henri_willig),
          body: "private made pagination #{i}",
          private: true
        )
      end

      get user_comments_path('henri_willig')

      expect(response.body).to include("page_made=2")
    end

    it "is visible to user who made the comment on their comment page" do
      create_user_session(users(:henri_willig))
      get user_comments_path('henri_willig')

      expect(response.body).to include(comment.body)
    end

    it "is visible to admin" do
      create_user_session(users(:sudara))
      get user_comments_path('henri_willig')

      expect(response.body).to include(comment.body)
    end

    it "is visible to mod" do
      create_user_session(users(:sandbags))
      get user_comments_path('henri_willig')

      expect(response.body).to include(comment.body)
    end

    it "is not visible to guest" do
      get user_comments_path('henri_willig')

      expect(response.body).not_to include(comment.body)
    end

    it "is not visible to normal user" do
      create_user_session(users(:joeblow))
      get user_comments_path('henri_willig')

      expect(response.body).not_to include(comment.body)
    end
  end

  context "private comments received by user" do
    let(:comment) { comments(:private_comment_on_asset_by_guest) }

    it "is visible to track owner" do
      create_user_session(users(:arthur))
      get user_comments_path('arthur')

      expect(response.body).to include(comment.body)
    end

    it "is visible to admin" do
      create_user_session(users(:sudara))
      get user_comments_path('arthur')

      expect(response.body).to include(comment.body)
    end

    it "is visible to mod" do
      create_user_session(users(:sandbags))
      get user_comments_path('arthur')

      expect(response.body).to include(comment.body)
    end

    it "is not visible to guest" do
      get user_comments_path('arthur')

      expect(response.body).not_to include(comment.body)
    end

    it "is not visible to other user" do
      create_user_session(users(:henri_willig))
      get user_comments_path('arthur')

      expect(response.body).not_to include(comment.body)
    end
  end

  context "private comments on overall index" do
    let(:comment) { comments(:private_comment_on_asset_by_user) }

    it "uses a separate page key for spam pagination" do
      create_user_session(users(:sudara))
      21.times do |i|
        Comment.create!(
          commentable: assets(:valid_arthur_mp3),
          user: users(:arthur),
          commenter: users(:henri_willig),
          body: "spam pagination #{i}",
          is_spam: true
        )
      end

      get "/comments"

      expect(response.body).to include("page_spam=2")
    end

    it "is not visible to receiver of the private comment" do
      create_user_session(users(:arthur))
      get "/comments"

      expect(response.body).not_to include(comment.body)
    end

    it "is visible to admin" do
      create_user_session(users(:sudara))
      get "/comments"

      expect(response.body).to include(comment.body)
    end

    it "is visible to mod" do
      create_user_session(users(:sandbags))
      get "/comments"

      expect(response.body).to include(comment.body)
    end

    it "is not visible to guest" do
      get "/comments"

      expect(response.body).not_to include(comment.body)
    end

    it "is not visible to other user" do
      create_user_session(users(:henri_willig))
      get "/comments"

      expect(response.body).not_to include(comment.body)
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
      expect(Comment.with_deleted.find(comment.id).is_spam).to be true
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

require "rails_helper"

RSpec.describe CommentsController, type: :controller do
  fixtures :users, :comments, :assets
  include ActiveJob::TestHelper

  context "basics" do
    it 'should allow anyone to view the comments index' do
      get :index
      assigns(:comments)
      expect(response).to be_successful
    end

    it 'should allow guest to comment on a track (via xhr)' do
      params = { :comment => { "body" => "Comment", "private" => "0", "commentable_type" => "Asset", "commentable_id" => 1 }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      expect { post :create, params: params, xhr: true }.to change { Comment.count }.by(1)
      expect(response).to be_successful
    end

    it 'should allow user comment on a track (via xhr)' do
      login(:arthur)
      params = { :comment => { "body" => "Comment", "private" => "0", "commentable_type" => "Asset", "commentable_id" => 1 }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      post :create, params: params, xhr: true
      expect(response).to be_successful
    end

    it 'should allow private comment on track' do
      login(:arthur)
      params = { :comment => { "body" => "Comment", "private" => 1, "commentable_type" => "Asset", "commentable_id" => 1 }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      post :create, params: params, xhr: true
      expect(response).to be_successful
    end

    it 'should send email to track owner if comment wasnt spam' do
      login(:sudara)
      params = { :comment => { "body" => "Comment yo!", "commentable_type" => "Asset", "commentable_id" => 4 }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      expect { post :create, params: params, xhr: true}.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    # perform_enqueued_jobs

    it 'should not email track owner if comment is spam' do
      login(:arthur)
      # the "viagra-test-123" guarantees a spam response
      params = { :comment => { "body" => "viagra-test-123", "private" => 1, "commentable_type" => "Asset", "commentable_id" => 4 }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      expect do
         post :create, params: params, xhr: true
         Comment.last.update_attribute(:is_spam, true)
      end.to change { ActionMailer::Base.deliveries.size }.by(0)
    end

    it "should increment comment_count if comment was not a spam" do
      params = { :comment => { "body" => "Comment", "private" => "0", "commentable_type" => "Asset", "commentable_id" => 1 }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      expect { post :create, params: params, xhr: true }.to change { Asset.first.comments_count }.by(1)
    end

    it "should not increment comment_count if comment is spam" do
      # the "viagra-test-123" guarantees a spam response
      params = { :comment => { "body" => "viagra-test-123", "private" => 1, "commentable_type" => "Asset", "commentable_id" => 4 }, "user_id" => users(:sudara).login, "track_id" => assets(:valid_mp3).permalink }
      post :create, params: params, xhr: true
      expect(Asset.find(1).comments_count).to eq(0)
    end
  end

  context "private comments made by user" do
    it "should be visible to private user viewing their own shit" do
      login(:arthur)
      get :index, params: { login: 'arthur' }
      expect(assigns(:comments_made)).to include(comments(:private_comment_on_asset_by_user))
    end

    it "should be visible to admin" do
      login(:sudara)
      get :index, params: { login: 'arthur' }
      expect(assigns(:comments_made)).to include(comments(:private_comment_on_asset_by_user))
    end

    it "should be visible to mod" do
      login(:sandbags)
      get :index, params: { login: 'arthur' }
      expect(assigns(:comments_made)).to include(comments(:private_comment_on_asset_by_user))
    end

    it "should not be visible to guest" do
      get :index, params: { login: 'arthur' }
      expect(assigns(:comments_made)).not_to include(comments(:private_comment_on_asset_by_user))
    end

    it "should not be visible to normal user" do
      login(:joeblow)
      get :index, params: { login: 'arthur' }
      expect(assigns(:comments_made)).not_to include(comments(:private_comment_on_asset_by_user))
    end
  end

  context "private comments on index" do
    it "should be visible to admin" do
      login(:sudara)
      get :index
      expect(assigns(:comments)).to include(comments(:private_comment_on_asset_by_guest))
    end

    it "should be visible to mod" do
      login(:sandbags)
      get :index
      expect(assigns(:comments)).to include(comments(:private_comment_on_asset_by_guest))
    end

    it "should not be visible to guest" do
      get :index
      expect(assigns(:comments)).not_to include(comments(:private_comment_on_asset_by_guest))
    end

    it "should not be visible to normal user" do
      login(:arthur)
      get :index
      expect(assigns(:comments)).not_to include(comments(:private_comment_on_asset_by_guest))
    end
  end
end

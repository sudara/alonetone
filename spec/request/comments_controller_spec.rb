require 'rails_helper'

RSpec.describe CommentsController, type: :request do
  before do
    akismet_stub_response_ham
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
end

require "rails_helper"

RSpec.describe CommentsController, type: :controller do

  fixtures :users, :comments, :assets

  context "basics" do

    it 'should allow anyone to view the comments index' do
      get :index
       assigns(:comments)
      expect(response).to be_success
    end

    it 'should allow guest to comment on a track (via xhr)' do
      params = {:comment => {"body"=>"Comment", "private"=>"0", "commentable_type"=>"Asset", "commentable_id" => 1}, "user_id"=> users(:sudara).login, "track_id"=> assets(:valid_mp3).permalink}
      expect { xhr :post, :create, params }.to change{ Comment.count}.by(1)
      expect(response).to be_success
    end

    it 'should allow guest to comment on a blog post' do
      params = {:comment => {"body"=>"Comment", "private"=>"0", "commentable_type"=>"Update","commentable_id"=> 1 }}
      xhr :post, :create, params
      expect(response).to be_success
    end

    it 'should allow user comment on a track (via xhr)' do
      login(:arthur)
      params = {:comment => {"body"=>"Comment", "private"=>"0", "commentable_type"=>"Asset", "commentable_id" => 1}, "user_id"=> users(:sudara).login, "track_id"=> assets(:valid_mp3).permalink}
      xhr :post, :create, params
      expect(response).to be_success
    end

    it 'should allow private comment on track' do
      login(:arthur)
      params = {:comment => {"body"=>"Comment", "private"=> 1, "commentable_type"=>"Asset", "commentable_id" => 1}, "user_id"=> users(:sudara).login, "track_id"=> assets(:valid_mp3).permalink }
      xhr :post, :create, params
      expect(response).to be_success
    end
  end

  context "private comments made by user" do
    it "should be visible to private user viewing their own shit" do
      login(:arthur)
      get :index, :login => 'arthur'
      expect(assigns(:comments_made)).to include(comments(:private_comment_on_asset_by_user))
    end

    it "should be visible to admin" do
      login(:sudara)
      get :index, :login => 'arthur'
      expect(assigns(:comments_made)).to include(comments(:private_comment_on_asset_by_user))
    end

    it "should be visible to mod" do
      login(:sandbags)
      get :index, :login => 'arthur'
      expect(assigns(:comments_made)).to include(comments(:private_comment_on_asset_by_user))
    end


    it "should not be visible to guest" do
      get :index, :login => 'arthur'
      expect(assigns(:comments_made)).not_to include(comments(:private_comment_on_asset_by_user))
    end

    it "should not be visible to normal user" do
      login(:joeblow)
      get :index, :login => 'arthur'
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

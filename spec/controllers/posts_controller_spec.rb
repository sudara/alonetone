require "rails_helper"

RSpec.describe PostsController, 'basics', type: :controller do
  fixtures :forums, :topics, :posts, :users
  spec_tagging

  #it "should show a topic" do
  #  get :show, :id => 1, :forum_id => 'testforum'
  #  response.should be_success
  #end

  def create_post
    post :create, :forum_id => 'testforum', :topic_id => 'firsttopic', :post => {:body => 'howdy'}
  end

  it "should not allow a post from a guest user" do
    expect {create_post}.not_to change{ Post.count }
    expect(response).to be_redirect
  end

  it "should allow a post from a logged in user" do
    login(:arthur)
    expect{ create_post }.to change{ Post.count }.by(1)
    expect(response).to be_redirect
  end


 # it "should NOT let a not-logged person edit a playlist" do
 #   # not logged in
 #   edit_sudaras_playlist
 #   response.should_not be_success
 #   response.should redirect_to('/login')
 # end
 #
 # it "should not let a not-logged in user update their playlist" do
 #   put :update, :id => 1, :permalink => 'owp', :user_id => 'sudara', :title => 'new title'
 #   response.should_not be_success
 #   response.should redirect_to('/login')
 # end
 #
 # [:sort_tracks, :add_track, :remove_track, :attach_pic].each do |postable|
 #   it "should forbid any modification of playlist via #{postable.to_s} by non logged in" do
 #     post postable, :id => 1, :permalink => 'owp', :user_id => 'sudara'
 #     response.should_not be_success
 #     response.should redirect_to('/login')
 #   end
 # end
 #
 # it "should not mistake a playlist for belonging to a user when it doesn't" do
 #   login(:arthur)
 #   get :edit, :id=>'1', :permalink => 'owp', :user_id=> 'sudara'
 #   response.should_not be_success
 # end
 #
 # it "should not let any old logged in user edit their playlist" do
 #   # logged in
 #   login(:arthur)
 #   edit_sudaras_playlist
 #   response.should_not be_success
 # end
 #
 # it 'should let a user edit their own playlist' do
 #   login(:arthur)
 #   edit_arthurs_playlist
 #   response.should be_success
 # end
 #
 # context "sorting" do
 #   it 'should display albums to sort' do
 #     login(:sudara)
 #     get :sort, :user_id => 'sudara'
 #     response.should be_success
 #   end
 #
 #   it 'should allow sorting of playlists' do
 #     login(:sudara)
 #     xhr :post, :sort, :user_id => 'sudara', :playlist => [3,1]
 #     response.should be_success
 #   end
 # end
 #
 # context "deletion" do
 #   it "should not let a non-logged in person delete a playlist" do
 #     post :destroy, :id => '1', :permalink => 'owp', :user_id => 'sudara'
 #     response.should_not be_success
 #   end
 #
 #   it 'should not let any old user delete a playlist' do
 #     login(:arthur)
 #     post :destroy, :id => '1', :permalink => 'owp', :user_id => 'sudara'
 #     response.should_not be_success
 #   end
 #
 #   it 'should let an admin delete any playlist' do
 #     login(:sudara)
 #     lambda{post :destroy, :id => '2', :permalink => 'arthurs-playlist', :user_id => 'arthur'}.should change(Playlist, :count).by(-1)
 #   end
 #
 #   it 'should let a user delete their own playlist' do
 #     login(:arthur)
 #     lambda{post :destroy, :id => '2', :permalink => 'arthurs-playlist', :user_id => 'arthur'}.should change(Playlist, :count).by(-1)
 #   end
 # end
 #
 # context "add new pic" do
 #   it "should let a user upload a playlist photo" do
 #     login(:arthur)
 #     post :attach_pic, :id => 'arthurs-playlist', :user_id => 'arthur', :pic => {:pic => fixture_file_upload('images/jeffdoessudara.jpg','image/jpeg')}
 #     flash[:notice].should be_present
 #     response.should redirect_to(edit_user_playlist_path(users(:arthur),'arthurs-playlist'))
 #   end
 #
 #   it "should not let a user upload a new photo for another user" do
 #     login(:arthur)
 #     post :attach_pic, :id => 'owp', :user_id => 'sudara', :pic => {:pic => fixture_file_upload('images/jeffdoessudara.jpg','image/jpeg')}
 #     response.should redirect_to('/login')
 #   end
 # end
end

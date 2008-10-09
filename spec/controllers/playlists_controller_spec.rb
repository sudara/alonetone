require File.dirname(__FILE__) + '/../spec_helper'

describe PlaylistsController, "edit and delete" do
  
  fixtures :playlists
  
  # 
  # throughout this file, we specify id and permalink, though in reality we pretty much use just a permalink
  #
   
  it "should let a not-logged person edit a playlist" do
    # not logged in
    logout
    edit_sudaras_playlist
    response.should_not be_success
    response.should redirect_to('/sessions/new') 
  end
  
  it "should not let a not-logged in user update their playlist" do
    logout
    put :update, :id => 1, :permalink => 'owp', :login => 'sudara', :title => 'new title'
    response.should_not be_success
    response.should redirect_to('/sessions/new') 
  end

  [:sort_tracks, :add_track, :remove_track, :attach_pic, :set_playlist_description, :set_playlist_title].each do |postable| 
    it "should forbid any modification of playlist via #{postable.to_s} by non logged in" do
      logout
      post postable, :id => 1, :permalink => 'owp', :login => 'sudara'
      response.should_not be_success
      response.should redirect_to('/sessions/new') 
    end
  end

  #['sort_tracks', 'add_track', 'remove_track'].each do |postable| 
  #  it 'should forbid any modification of playlist by non logged in' do
  #    login_as(:arthur)
  #    post postable, :id => 2, :permalink => 'arthurs-playlist', :login => 'arthur'
  #    response.should be_success
  #  end
  #end 
  
  [:show].each do |gettable|
    it "should allow #{gettable}" do
      logout
      get gettable, :id => 1, :permalink => 'owp', :login => 'sudara'
      response.should be_success
    end
  end
  
  
  it "should not let a non-logged in person delete a playlist" do
    post :destroy, :id => '1', :permalink => 'owp', :login => 'sudara'
    response.should_not be_success
  end
  
  it 'should not let any old user delete a playlist' do 
    login_as(:arthur)
    post :destroy, :id => '1', :permalink => 'owp', :login => 'sudara'
    response.should_not be_success
  end
  
  it "should not mistake a playlist for belonging to a user when it doesn't" do
    login_as(:arthur)
    get :edit, :id=>'1', :permalink => 'owp', :login=> 'sudara'
    response.should_not be_success
  end
  
  it "should not let any old logged in user edit their playlist" do
    # logged in
    login_as(:arthur)
    edit_sudaras_playlist
    response.should_not be_success
  end
  
  it 'should let a user edit their own playlist' do 
    login_as(:arthur)
    edit_arthurs_playlist
    response.should be_success
  end

  it 'should let an admin delete any playlist' do 
    login_as(:sudara)
    lambda{post :destroy, :id => '2', :permalink => 'arthurs-playlist', :login => 'arthur'}.should change(Playlist, :count).by(-1)
  end
  
  it 'should let a user delete their own playlist' do
    login_as(:arthur)
    lambda{post :destroy, :id => '2', :permalink => 'arthurs-playlist', :login => 'arthur'}.should change(Playlist, :count).by(-1)
  end
end

describe PlaylistsController, "sharing and exporting" do
  
  it "should deliver us tasty xml for single playlist" do
    request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => '1', :login => 'sudara', :permalink => 'owp' 
    response.should be_success
  end
  
end
 
  def edit_sudaras_playlist
    # a little ghetto, rspec won't honor string ids
    get :edit, :id => '1', :permalink => 'owp', :login => 'sudara'
  end
  
  def edit_arthurs_playlist
    get :edit, :id => '2', :permalink => 'arthurs-playlist', :login => 'arthur'
  end
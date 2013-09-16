# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe PlaylistsController, 'permissions' do
  
  fixtures :playlists, :users
  
  it "should NOT let a not-logged person edit a playlist" do
    # not logged in
    edit_sudaras_playlist
    response.should_not be_success
    response.should redirect_to('/login') 
  end
  
  it "should not let a not-logged in user update their playlist" do
    put :update, :id => 1, :permalink => 'owp', :user_id => 'sudara', :title => 'new title'
    response.should_not be_success
    response.should redirect_to('/login') 
  end

  [:sort_tracks, :add_track, :remove_track, :attach_pic].each do |postable| 
    it "should forbid any modification of playlist via #{postable.to_s} by non logged in" do
      post postable, :id => 1, :permalink => 'owp', :user_id => 'sudara'
      response.should_not be_success
      response.should redirect_to('/login') 
    end
  end

  #['sort_tracks', 'add_track', 'remove_track'].each do |postable| 
  #  it 'should forbid any modification of playlist by non logged in' do
  #    login(:arthur)
  #    post postable, :id => 2, :permalink => 'arthurs-playlist', :user_id => 'arthur'
  #    response.should be_success
  #  end
  #end 
  
  [:show].each do |gettable|
    it "should allow #{gettable}" do
      get gettable, :id => 1, :permalink => 'owp', :user_id => 'sudara'
      response.should be_success
    end
  end
  
  it "should not let a non-logged in person delete a playlist" do
    post :destroy, :id => '1', :permalink => 'owp', :user_id => 'sudara'
    response.should_not be_success
  end
  
  it 'should not let any old user delete a playlist' do 
    login(:arthur)
    post :destroy, :id => '1', :permalink => 'owp', :user_id => 'sudara'
    response.should_not be_success
  end
  
  it "should not mistake a playlist for belonging to a user when it doesn't" do
    login(:arthur)
    get :edit, :id=>'1', :permalink => 'owp', :user_id=> 'sudara'
    response.should_not be_success
  end
  
  it "should not let any old logged in user edit their playlist" do
    # logged in
    login(:arthur)
    edit_sudaras_playlist
    response.should_not be_success
  end
  
  it 'should let a user edit their own playlist' do 
    login(:arthur)
    edit_arthurs_playlist
    response.should be_success
  end

  it 'should let an admin delete any playlist' do 
    login(:sudara)
    lambda{post :destroy, :id => '2', :permalink => 'arthurs-playlist', :user_id => 'arthur'}.should change(Playlist, :count).by(-1)
  end
  
  it 'should let a user delete their own playlist' do
    login(:arthur)
    lambda{post :destroy, :id => '2', :permalink => 'arthurs-playlist', :user_id => 'arthur'}.should change(Playlist, :count).by(-1)
  end
end

describe PlaylistsController, "sharing and exporting" do
  
  it "should deliver us tasty xml for single playlist" do
    request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => '1', :user_id => 'sudara', :permalink => 'owp' 
    response.should be_success
  end
  
end
 
  def edit_sudaras_playlist
    # a little ghetto, rspec won't honor string ids
    get :edit, :id => '1', :permalink => 'owp', :user_id => 'sudara'
  end
  
  def edit_arthurs_playlist
    get :edit, :id => '2', :permalink => 'arthurs-playlist', :user_id => 'arthur'
  end

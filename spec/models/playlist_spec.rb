require File.dirname(__FILE__) + '/../spec_helper'

describe Playlist do
  fixtures :playlists, :tracks, :assets, :users 
  
  it 'should be valid with title, description, user' do
    playlists(:owp).should be_valid
  end
  
  it 'should use its permalink as param' do
    playlists(:owp).permalink.should == playlists(:owp).to_param
  end
  
  it 'should know if it has tracks' do
    playlists(:mix).has_tracks?.should == true
  end
  
  it 'should know if it is empty (does not have tracks)' do
    playlists(:empty).empty?.should == true
  end
  
  it "should know playlist is an album" do
    playlists(:owp).is_mix?.should == false
  end
  
  it 'should be valid' do
    playlists(:owp).should be_valid
  end
  
  it "should update a-ok" do
    playlist = playlists(:mix) 
    playlist.save.should == true
  end
  
  it 'should know if it is a mix on update' do 
    playlist = playlists(:mix)
    playlist.is_mix?.should == true
  end
  
  it 'should always belong to a user' do 
    playlists(:mix).user.should_not be_nil
  end

  it "should deliver its tracks in order of the position" do 
    playlists(:owp).tracks.first.position.should == 1
    playlists(:owp).tracks[1].position.should == 2
  end
  
  context "favorites" do 
    it 'should create a new playlist for a user who does not have one' do
      users(:sandbags).playlists.favorites.should_not be_present
      users(:sandbags).toggle_favorite(assets(:valid_mp3))
      users(:sandbags).playlists.favorites.first.should be_present
      users(:sandbags).playlists.favorites.first.permalink.should_not be_nil
    end
  end
  
end

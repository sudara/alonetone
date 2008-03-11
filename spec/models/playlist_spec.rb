require File.dirname(__FILE__) + '/../spec_helper'

describe Playlist do
  fixtures :playlists, :tracks, :assets
  
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
    @playlist = playlists(:mix)
    @playlist.save.should == true
  end
  
  it 'should know if it is a mix on update' do 
    @playlist = playlists(:mix)
    @playlist.save
    @playlist.is_mix?.should == true
  end
  
end

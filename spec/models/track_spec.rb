# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Track do
  fixtures :playlists, :tracks, :assets, :users
  
  it "should be valid with a asset_id and a playlist_id" do 
    tracks(:owp1).should be_valid
  end
  
  it "is not valid without a playlist_id" do 
    tracks(:no_playlist_id).should_not be_valid
  end
  
  context "as a fav" do 
    subject { users(:arthur).tracks.favorites.create(:asset_id => 1) }
    it "should create a favorite playlist if its the first fav" do 
      expect{subject}.to change{Track.count}
    end
  
    it 'should use an existing favorites playlist' do 
    
    end
  end
end
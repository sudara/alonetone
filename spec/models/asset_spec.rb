# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

include ActionDispatch::TestProcess
def new_track(file)
  upload_file = fixture_file_upload(File.join('assets',file),'audio/mpeg')
  Asset.create({:user_id => 1, :mp3 => upload_file })
end

describe Asset do
  fixtures :users, :assets
  context "validation" do
    it 'can be an mp3 file' do
      assets(:valid_mp3).should be_valid
    end
  
    it 'cannot be a zip file' do
      assets(:valid_zip).should_not be_valid
    end 
  
    it 'cannot be any other filetype' do 
      assets(:invalid_file).should_not be_valid
    end
  
    it 'cannot be over 60 megs' do
      assets(:too_big_file).should_not be_valid
    end
  
    it 'should give its length in a human friendly way' do 
      assets(:valid_mp3).length.should == '0:45'
    end
  end
  
  context "uploading" do
    it "should only require a name and mp3 " do
      asset = new_track('muppets.mp3')
      asset.should_not be_new_record
      asset.errors.should_not be_present
    end
    
    it "should catch empty or bogus files" do
      asset = new_track('empty.mp3')
      asset.should be_new_record
      asset.errors.should be_present
    end
  
    it "should increase the user's count" do
      expect{ new_track('muppets.mp3').save }.to change(Asset, :count).by(1)
    end
    
    it "should send out email to followers after upload" do 
      # pending
    end
  end
  
  context "mp3 tags" do
    it "should use tag2 TT2 as name if present" do
      asset = new_track('muppets.mp3')
      asset.name.should == 'Old Muppet Men Booing'
    end
  
    it 'should still work even when tags are empty and the name is weird' do 
      asset = new_track('_ .mp3')
      asset.permalink.should == 'untitled'
      asset.name.should == 'untitled'
    end
  
    it 'should handle strange charsets / characters in title tags' do
      asset = new_track('japanese-characters.mp3')
      asset.name.should == '01-¶ÔµÄÈË' # name is still 01-\266Ե??\313"
      asset.mp3_file_name.should == 'japanese-characters.mp3'
    end
  
    it 'should handle empty name in mp3 tag' do 
      asset = new_track('japanese-characters.mp3')
      asset.permalink.should == "01-oaee" # name is 01-\266Ե??\313"
      asset.title = 'bee'
      asset.save
      asset.permalink.should == 'bee' 
    end

    it 'should cope with non-english filenames' do 
      asset = new_track('中文測試.mp3')
      asset.save.should == true
      asset.mp3_file_name == '中文測試.mp3'
    end
  
    it 'should handle umlauts and non english characters in the filename' do
      asset = new_track('müppets.mp3')
      asset.mp3_file_name.should == 'müppets.mp3' 
    end
  
    it 'should handle permalink with ???? as tags, default to untitled' do 
      asset = new_track('中文測試.mp3')
      asset.name.should == "中文測試"
      asset.permalink.should_not be_blank
      asset.permalink.should == "untitled"
    end
  
    it 'should use the mp3 tag1 title as name if present' do 
      asset = new_track('tag1.mp3')
      asset.name.should == "Mark S Williams"
    end
  
    it 'should use the filename as name if no tags are present' do
      asset = new_track('titleless.mp3')
      asset.name.should == 'Titleless'  
    end
  
    it 'should generate a permalink from tags' do 
      asset = new_track('tag2.mp3')
      asset.permalink.should == 'put-a-nickel-on-my-door'
    end
    
    it 'should generate unique permalinks' do
      asset = new_track('tag2.mp3')
      asset2 = new_track('tag2.mp3')
      asset2.permalink.should == 'put-a-nickel-on-my-door-1'
    end
  
    it 'should make sure to grab bitrate and length in seconds' do
      asset = new_track('muppets.mp3')
      asset.bitrate.should == 192
      asset.length.should == '0:13'
    end
  
    it 'should open up a zip and dig out valid mp3 files' do
      #asset = new_track('1valid-1invalid.zip', 'application/zip')
      # lambda{asset.save}.should change(Asset, :count).by(1)
    end
  end
end


describe Asset, 'on update' do
  
  it 'should regenerate a permalink after the title is changed' do 
    asset = new_track('muppets.mp3')
    asset.save
    asset.title = 'New Muppets 123'
    asset.save
    asset.permalink.should == 'new-muppets-123'
  end
  
  
end
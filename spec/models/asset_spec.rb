require File.dirname(__FILE__) + '/../spec_helper'

include ActionDispatch::TestProcess
def new_track(file)
  upload_file = File.open(File.join('spec/fixtures/assets',file))
  Asset.new({:user_id => 1, :mp3 => upload_file })
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
  
    it "should catch empty or bogus files" do
      asset = new_track('empty.mp3')
      asset.should be_new_record
    end
  end
  
  context "uploading" do
    it "should only require a name and mp3 " do
      asset = new_track('muppets.mp3')
      asset.should be_valid
      asset.save
      asset.should_not be_new_record
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
      asset.save 
      asset.name.should == 'Old Muppet Men Booing'
    end
  
    it 'should still work even when tags are empty and the name is weird' do 
      asset = new_track('_ .mp3')
      asset.save
      asset.permalink.should == 'untitled'
      asset.name.should == 'untitled'
    end
  
    it 'should handle strange charsets / characters in title tags' do
      asset = new_track('japanese-characters.mp3')
      asset.save
      asset.permalink.should == 'untitled' # name is still 01-\266Ե??\313"
      asset.mp3.filename.should == 'japanese-characters.mp3'
    end
  
    it 'should handle empty name in mp3 tag' do 
      asset = new_track('japanese-characters.mp3')
      asset.save
      asset.permalink.should == "untitled" # name is 01-\266Ե??\313"
      asset.title = 'bee'
      asset.save
      asset.permalink.should == 'bee' 
    end
  
    it 'should handle non-english filenames and default to untitled' do 
      asset = new_track('中文測試.mp3')
      asset.save.should == true
      asset.filename.should == '中文測試.mp3'
    end
  
    it 'should handle umlauts and non english characters in the filename' do
      asset = new_track('müppets.mp3')
      asset.save
      asset.filename.should == 'müppets.mp3' 
    end
  
    it 'should handle titles with only ???? and default to untitled' do 
      asset = new_track('中文測試.mp3')
      asset.save.should == true
      asset.permalink.should == 'untitled'
      asset.title = "中文測試"
      asset.save.should == true
      asset.permalink.should == 'untitled'
    end
  
    it 'should use the mp3 tag1 title as name if present' do 
      asset = new_track('tag1.mp3')
      asset.name.should == "Mark S Williams"
    end
  
    it 'should use the filename as name if no tags are present' do
      asset = new_track('titleless.mp3')
      asset.name.should == 'Titleless'  
    end
  
    it 'should generate a permalink' do 
      asset = new_track('tag2.mp3')
      asset.permalink.should == 'put-a-nickel-on-my-door'
    end
  
    it 'should make sure to grab bitrate and length in seconds' do
      asset = new_track('muppets.mp3')
      asset.bitrate.should == 192
      asset.length.should == '0:14'
    end
  
    it 'should open up a zip and dig out valid mp3 files' do
      asset = new_track('1valid-1invalid.zip', 'application/zip')
      lambda{asset.save}.should change(Asset, :count).by(1)
    end
  end
end


describe Asset, 'on update' do
  
  it 'should regenerate a permalink after the title is changed' do 
    asset = new_track('muppets.mp3')
    asset.save
    asset.title = 'New Muppets'
    asset.save
    asset.permalink.should == 'new-muppets'
  end
end
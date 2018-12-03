require "rails_helper"

include ActionDispatch::TestProcess
def new_track(file)
  upload_file = fixture_file_upload(File.join('assets', file), 'audio/mpeg')
  Asset.create(user_id: 1, mp3: upload_file)
end

RSpec.describe Asset, type: :model do
  fixtures :users, :assets
  context "validation" do
    it 'can be an mp3 file' do
      expect(assets(:valid_mp3)).to be_valid
    end

    it 'cannot be a zip file' do
      expect(assets(:valid_zip)).not_to be_valid
    end

    it 'cannot be any other filetype' do
      expect(assets(:invalid_file)).not_to be_valid
    end

    it 'cannot be over 60 megs' do
      expect(assets(:too_big_file)).not_to be_valid
    end

    it 'should give its length in a human friendly way' do
      expect(assets(:valid_mp3).length).to eq('0:45')
    end
  end

  context "uploading" do
    it "should only require a name and mp3 " do
      asset = new_track('muppets.mp3')
      expect(asset).not_to be_new_record
      expect(asset.errors).not_to be_present
    end

    it "should catch empty or bogus files" do
      asset = new_track('empty.mp3')
      expect(asset).to be_new_record
      expect(asset.errors).to be_present
    end

    it "should increase the user's count" do
      expect { new_track('muppets.mp3').save }.to change(Asset, :count).by(1)
    end

    it "should not allow zipfiles" do
      expect { new_track('1valid-1invalid.zip').save }.not_to change(Asset, :count)
    end
  end

  context "zip files" do
    it "allow mp3 files to be extracted" do
      file = fixture_file_upload(File.join('assets', '1valid-1invalid.zip'), 'application/zip')
      expect { |b| Asset.extract_mp3s(file, &b) }.to yield_control.once
    end

    it "names mp3s after what they are called within the zip file" do
      files = []
      zip = fixture_file_upload(File.join('assets', '1valid-1invalid.zip'), 'application/zip')
      Asset.extract_mp3s(zip) do |file|
        files << file
      end
      expect(files.first.path.split('.').last).to eql('mp3')
      expect(files.first.path.split('/').last).to start_with('muppets')
    end

    it "doesn't barf on fake zip files, hands it to paperclip to validate" do
      file = fixture_file_upload(File.join('assets', 'broken.zip'), 'application/zip')
      expect { |b| Asset.extract_mp3s(file, &b) }.to yield_control.once
    end
  end

  context "download from url" do
    it "handles dropbox links well" do
      expect(Asset.parse_external_url('https://www.dropbox.com/s/dz1rla1x3az0tr7/slow%20motion.mp3?dl=0').to_s[-1]).to eql('1')
    end
  end

  context "mp3 tags" do
    it "should use tag2 TT2 as name if present" do
      asset = new_track('muppets.mp3')
      expect(asset.name).to eq('Old Muppet Men Booing')
    end

    it 'should still work even when tags are empty and the name is weird' do
      asset = new_track('_ .mp3')
      expect(asset.permalink).to eq('untitled')
      expect(asset.name).to eq('untitled')
    end

    it 'should handle strange charsets / characters in title tags' do
      asset = new_track('japanese-characters.mp3')
      expect(asset.name).to eq('01-¶ÔµÄÈË') # name is still 01-\266Ե??\313"
      expect(asset.mp3_file_name).to eq('japanese-characters.mp3')
    end

    it 'should handle empty name in mp3 tag' do
      asset = new_track('japanese-characters.mp3')
      expect(asset.permalink).to eq("01-oaee") # name is 01-\266Ե??\313"
      asset.title = 'bee'
      asset.save
      expect(asset.permalink).to eq('bee')
    end

    it 'should cope with non-english filenames' do
      asset = new_track('中文測試.mp3')
      expect(asset.save).to eq(true)
      asset.mp3_file_name == '中文測試.mp3'
    end

    it 'should handle umlauts and non english characters in the filename' do
      asset = new_track('müppets.mp3')
      expect(asset.mp3_file_name).to eq('müppets.mp3')
    end

    it 'should handle permalink with ???? as tags, default to untitled' do
      asset = new_track('中文測試.mp3')
      expect(asset.name).to eq("中文測試")
      expect(asset.permalink).not_to be_blank
      expect(asset.permalink).to eq("untitled")
    end

    it 'should use the mp3 tag1 title as name if present' do
      asset = new_track('tag1.mp3')
      expect(asset.name).to eq("Mark S Williams")
    end

    it 'should use the filename as name if no tags are present' do
      asset = new_track('titleless.mp3')
      expect(asset.name).to eq('Titleless')
    end

    it 'should generate a permalink from tags' do
      asset = new_track('tag2.mp3')
      expect(asset.permalink).to eq('put-a-nickel-on-my-door')
    end

    it 'should generate unique permalinks' do
      asset = new_track('tag2.mp3')
      asset2 = new_track('tag2.mp3')
      expect(asset2.permalink).to eq('put-a-nickel-on-my-door-1')
    end

    it 'should make sure to grab bitrate and length in seconds' do
      asset = new_track('muppets.mp3')
      expect(asset.bitrate).to eq(192)
      expect(asset.length).to eq('0:13')
    end

    it 'should open up a zip and dig out valid mp3 files' do
      # asset = new_track('1valid-1invalid.zip', 'application/zip')
      # lambda{asset.save}.should change(Asset, :count).by(1)
    end

    describe "#publish" do
      it "should update private false to true" do
        asset = assets(:private_track)
        asset.publish!
        asset.reload
        expect(asset.private).to eq(false)
      end
    end
  end
end

RSpec.describe Asset, 'on update', type: :model do
  fixtures :users, :assets

  it 'should regenerate a permalink after the title is changed' do
    asset = new_track('muppets.mp3')
    asset.save
    asset.title = 'New Muppets 123'
    asset.save
    expect(asset.permalink).to eq('new-muppets-123')
  end
end

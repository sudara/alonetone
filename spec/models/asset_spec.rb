require "rails_helper"

RSpec.describe Asset, type: :model do
  it 'replaces characters outside of the BMP from title so it saves to the database' do
    expect(Asset.new(title: '😢').title).to eq('�')
  end

  it 'replaces characters outside of the BMP from filename so it saves to the database' do
    expect(Asset.new(mp3_file_name: '😢.mp3').mp3_file_name).to eq('�.mp3')
  end

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
      asset = file_fixture_asset('muppets.mp3', content_type: 'audio/mpeg')
      expect(asset).not_to be_new_record
      expect(asset.errors).not_to be_present
    end

    it "should catch empty or bogus files" do
      asset = file_fixture_asset('empty.mp3', content_type: 'audio/mpeg')
      expect(asset).to be_new_record
      expect(asset.errors).to be_present
    end

    it "should increase the user's count" do
      user = users(:sudara)
      expect do
        file_fixture_asset('muppets.mp3', content_type: 'audio/mpeg', user: user)
      end.to change { user.reload.assets_count }.by(+1)
    end

    it "should not allow zipfiles" do
      asset = file_fixture_asset('1valid-1invalid.zip', content_type: 'application/zip')
      expect { asset.save }.not_to change(Asset, :count)
    end
  end

  context "zip files" do
    it "allow mp3 files to be extracted" do
      file = fixture_file_upload('files/1valid-1invalid.zip', 'application/zip')
      expect { |b| Asset.extract_mp3s(file, &b) }.to yield_control.once
    end

    it "names mp3s after what they are called within the zip file" do
      files = []
      zip = fixture_file_upload('files/1valid-1invalid.zip', 'application/zip')
      Asset.extract_mp3s(zip) do |file|
        files << file
      end
      expect(files.first.path.split('.').last).to eql('mp3')
      expect(files.first.path.split('/').last).to start_with('muppets')
    end

    it "doesn't barf on fake zip files, hands it to paperclip to validate" do
      file = fixture_file_upload('files/broken.zip', 'application/zip')
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
      asset = file_fixture_asset('muppets.mp3', content_type: 'audio/mpeg')
      expect(asset.name).to eq('Old Muppet Men Booing')
    end

    it 'should still work even when tags are empty and the name is weird' do
      asset = file_fixture_asset('_ .mp3', content_type: 'audio/mpeg')
      expect(asset.permalink).to eq('untitled')
      expect(asset.name).to eq('untitled')
    end

    it 'should handle strange charsets / characters in title tags' do
      asset = file_fixture_asset('japanese-characters.mp3', content_type: 'audio/mpeg')
      expect(asset.name).to eq('01-¶ÔµÄÈË') # name is still 01-\266Ե??\313"
      expect(asset.mp3_file_name).to eq('japanese-characters.mp3')
    end

    it 'should handle empty name in mp3 tag' do
      asset = file_fixture_asset('japanese-characters.mp3', content_type: 'audio/mpeg')
      expect(asset.permalink).to eq("01-oaee") # name is 01-\266Ե??\313"
      asset.title = 'bee'
      asset.save
      expect(asset.permalink).to eq('bee')
    end

    it 'should cope with non-english filenames' do
      asset = file_fixture_asset('中文測試.mp3', content_type: 'audio/mpeg')
      expect(asset.save).to eq(true)
      asset.mp3_file_name == '中文測試.mp3'
    end

    it 'should handle umlauts and non english characters in the filename' do
      filename = 'müppets.mp3'.mb_chars.normalize
      asset = file_fixture_asset(
        'muppets.mp3',
        filename: filename,
        content_type: 'audio/mpeg'
      )
      expect(asset.mp3_file_name).to eq(filename)
    end

    it 'should handle permalink with ???? as tags, default to untitled' do
      asset = file_fixture_asset('中文測試.mp3', content_type: 'audio/mpeg')
      expect(asset.name).to eq("中文測試")
      expect(asset.permalink).not_to be_blank
      expect(asset.permalink).to eq("untitled")
    end

    it 'should use the mp3 tag1 title as name if present' do
      asset = file_fixture_asset('tag1.mp3', content_type: 'audio/mpeg')
      expect(asset.name).to eq("Mark S Williams")
    end

    it 'should use the filename as name if no tags are present' do
      asset = file_fixture_asset('titleless.mp3', content_type: 'audio/mpeg')
      expect(asset.name).to eq('Titleless')
    end

    it 'should generate a permalink from tags' do
      asset = file_fixture_asset('tag2.mp3', content_type: 'audio/mpeg')
      expect(asset.permalink).to eq('put-a-nickel-on-my-door')
    end

    it 'should generate unique permalinks' do
      asset = file_fixture_asset('tag2.mp3', content_type: 'audio/mpeg')
      asset2 = file_fixture_asset('tag2.mp3', content_type: 'audio/mpeg')
      expect(asset2.permalink).to eq('put-a-nickel-on-my-door-1')
    end

    it 'should make sure to grab bitrate and length in seconds' do
      asset = file_fixture_asset('muppets.mp3', content_type: 'audio/mpeg')
      expect(asset.bitrate).to eq(192)
      expect(asset.length).to eq('0:13')
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

  context 'on update' do
    it 'should regenerate a permalink after the title is changed' do
      asset = file_fixture_asset('muppets.mp3', content_type: 'audio/mpeg')
      asset.title = 'New Muppets 123'
      asset.save
      expect(asset.permalink).to eq('new-muppets-123')
    end
  end
end

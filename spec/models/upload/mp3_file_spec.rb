# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload::Mp3File, type: :model do
  let(:user) { users(:will_studd) }
  let(:asset_attributes) { nil }
  let(:mp3_file_filename) { 'smallest.mp3' }
  let(:mp3_file) do
    Upload::Mp3File.new(
      user: user,
      file: file_fixture_tempfile(mp3_file_filename),
      filename: mp3_file_filename,
      asset_attributes: asset_attributes
    )
  end

  it 'processes' do
    expect(
      Upload::Mp3File.process(
        user: user,
        file: file_fixture_tempfile(mp3_file_filename),
        filename: mp3_file_filename
      )
    ).to be_kind_of(Upload::Mp3File)
  end

  context 'processing file without ID3 tags' do
    it 'builds a valid single asset' do
      expect(mp3_file.process).to eq(true)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to be_blank
      expect(asset.user).to eq(user)
      expect(asset.mp3_content_type).to eq('audio/mpeg')
      expect(asset.mp3_file_name).to eq(mp3_file_filename)
      expect(asset.mp3_file_size).to eq(72)
      expect(asset.private).to eq(false)
    end
  end

  context 'processing file with ID3 tags' do
    let(:mp3_file_filename) { 'piano.mp3' }

    it 'builds a valid single asset' do
      expect(mp3_file.process).to eq(true)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to be_blank
      expect(asset.user).to eq(user)
      expect(asset.album).to eq('Polderkaas')
      expect(asset.artist).to eq('Henri Willig')
      expect(asset.bitrate).to eq(64)
      expect(asset.length).to eq('0:04')
      expect(asset.samplerate).to eq(44100)
      expect(asset.title).to eq('Piano')
      expect(asset.id3_track_num).to eq(2)
      expect(asset.genre).to eq('Rock')
      expect(asset.mp3_content_type).to eq('audio/mpeg')
      expect(asset.mp3_file_name).to eq(mp3_file_filename)
      expect(asset.mp3_file_size).to eq(37352)
      expect(asset.private).to eq(false)
    end
  end

  context 'processing file with emoji in the filename' do
    let(:mp3_file_filename) { '🐬.mp3' }
    let(:mp3_file) do
      Upload::Mp3File.new(
        user: user,
        file: file_fixture_tempfile('smallest.mp3'),
        filename: mp3_file_filename
      )
    end

    it 'builds a valid single asset' do
      expect(mp3_file.process).to eq(true)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to be_blank
      expect(asset.user).to eq(user)
      expect(asset.name).to eq('🐬')
      expect(asset.mp3_file_name).to eq('🐬.mp3')
      expect(asset.private).to eq(false)
    end
  end

  context 'processing an empty file' do
    let(:mp3_file_filename) { 'empty.mp3' }

    it 'builds an invalid single asset' do
      expect(mp3_file.process).to eq(false)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to_not be_blank
      expect(asset.errors.details.keys).to eq(%i[mp3_content_type mp3])
      expect(asset.private).to eq(false)
    end
  end

  context 'processing an unsupported file' do
    let(:mp3_file_filename) { 'smallest.zip' }

    it 'builds an invalid single asset' do
      expect(mp3_file.process).to eq(false)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to_not be_blank
      expect(asset.errors.details.keys).to eq(%i[mp3_content_type mp3])
      expect(asset.private).to eq(false)
    end
  end

  context 'processing with additional attributes for assets' do
    let(:user_agent) do
      'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)'
    end
    let(:asset_attributes) do
      {
        private: true,
        user_agent: user_agent
      }
    end

    it 'applies attributes to assets it builds' do
      expect(mp3_file.process).to eq(true)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.private).to eq(true)
      expect(asset.user_agent).to eq(user_agent)
    end
  end

  context 'processing with explicit content-type' do
    let(:content_type) { 'audio/x-flac' }
    let(:mp3_file) do
      Upload::Mp3File.new(
        user: user,
        file: file_fixture_tempfile(mp3_file_filename),
        filename: mp3_file_filename,
        content_type: content_type
      )
    end

    it 'forwards content-type to audio file' do
      # It doesn't process because the content-type is not supported.
      expect(mp3_file.process).to eq(false)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.mp3_content_type).to eq(content_type)
    end
  end

  context 'processing with nil content-type' do
    let(:mp3_file) do
      Upload::Mp3File.new(
        user: user,
        file: file_fixture_tempfile(mp3_file_filename),
        filename: mp3_file_filename,
        content_type: nil
      )
    end

    it 'detects the content-type' do
      expect(mp3_file.process).to eq(true)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.mp3_content_type).to eq('audio/mpeg')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload::Mp3File, type: :model do
  let(:user) { users(:will_studd) }
  let(:asset_attributes) { nil }
  let(:fixture_filename) { 'smallest.mp3' }
  let(:filename) {
    'op1 virtual III the 2nd when Times are hard %live% (prod. THE MAN).mp3'
  }
  let(:mp3_file) do
    Upload::Mp3File.new(
      user: user,
      file: file_fixture_tempfile(fixture_filename),
      filename: filename,
      asset_attributes: asset_attributes
    )
  end

  it 'processes' do
    expect(
      Upload::Mp3File.process(
        user: user,
        file: file_fixture_tempfile(fixture_filename),
        filename: filename
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
      expect(asset.title).to eq(
        'op1 virtual III the 2nd when Times are hard %live% (prod. THE MAN)'
      )
      expect(asset.mp3_content_type).to eq('audio/mpeg')
      expect(asset.mp3_file_name).to eq(
        'op1 virtual III the 2nd when Times are hard -live- (prod. THE MAN).mp3'
      )
      expect(asset.mp3_file_size).to eq(72)
      expect(asset.private).to eq(false)
    end
  end

  context 'processing file with some blank ID3 tags' do
    let(:filename) { '_ .mp3' }
    let(:fixture_filename) { filename }

    it 'builds a valid single asset' do
      expect(mp3_file.process).to eq(true)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to be_blank
      expect(asset.user).to eq(user)
      expect(asset.title).to eq('_')
      expect(asset.mp3_content_type).to eq('audio/mpeg')
      expect(asset.mp3_file_name).to eq(filename)
      expect(asset.mp3_file_size).to eq(3415280)
      expect(asset.private).to eq(false)
    end
  end

  context 'processing file with ID3 tags' do
    let(:fixture_filename) { 'piano.mp3' }

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
      expect(asset.mp3_file_name).to eq(
        'op1 virtual III the 2nd when Times are hard -live- (prod. THE MAN).mp3'
      )
      expect(asset.mp3_file_size).to eq(37352)
      expect(asset.private).to eq(false)
    end
  end

  context 'processing file with emoji in the filename' do
    let(:filename) { '🐬.mp3' }

    it 'builds a valid single asset' do
      expect(mp3_file.process).to eq(true)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to be_blank
      expect(asset.user).to eq(user)
      expect(asset.title).to eq('🐬')
      expect(asset.name).to eq('🐬')
      expect(asset.mp3_file_name).to eq('🐬.mp3')
      expect(asset.private).to eq(false)
    end
  end

  context 'processing an empty file' do
    let(:fixture_filename) { 'empty.mp3' }

    it 'builds an asset' do
      expect(mp3_file.process).to eq(false)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to_not be_blank
      expect(asset.errors.details.keys).to eq(%i[audio_file])
      expect(asset.private).to eq(false)
    end
  end

  context 'processing an unsupported file' do
    let(:filename) { 'smallest.zip' }
    let(:fixture_filename) { filename }

    it 'builds an invalid single asset' do
      expect(mp3_file.process).to eq(false)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to_not be_blank
      expect(asset.errors.details.keys).to eq(%i[audio_file])
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

  # Active Storage identifies the blob's content-type from the file bytes
  # (via Marcel) when the attachment is built, so the Asset whitelist always
  # validates Marcel's result, not the caller's claim. This guards the
  # safety-net: if a non-audio file reaches Upload::Mp3File (bypassing the
  # zip-vs-audio routing in Upload), validation still rejects it.
  context 'processing a non-audio file' do
    let(:fixture_filename) { 'readme.txt' }
    let(:filename) { 'readme.txt' }

    it 'rejects the upload' do
      expect(mp3_file.process).to eq(false)
      asset = mp3_file.assets.first
      expect(asset.errors[:audio_file]).to be_present
    end
  end
end

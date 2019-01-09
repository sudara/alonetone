# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload::Mp3File, type: :model do
  let(:user) { users(:will_studd) }
  let(:mp3_file_filename) { 'smallest.mp3' }
  let(:mp3_file) do
    Upload::Mp3File.new(
      user: user,
      file: file_fixture_tempfile(mp3_file_filename),
      filename: mp3_file_filename
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
      expect(asset.mp3_content_type).to eq('audio/mpeg')
      expect(asset.mp3_file_name).to eq(mp3_file_filename)
      expect(asset.mp3_file_size).to eq(37352)
      expect(asset.title).to eq('Piano')
      expect(asset.length).to eq('0:04')
      expect(asset.genre).to eq('Rock')
      expect(asset.samplerate).to eq(44100)
      expect(asset.bitrate).to eq(64)
    end
  end

  context 'processing a broken file' do
    let(:mp3_file_filename) { 'emptytags.mp3' }

    it 'builds an invalid single asset' do
      expect(mp3_file.process).to eq(false)
      expect(mp3_file.assets.length).to eq(1)

      asset = mp3_file.assets.first
      expect(asset.errors).to_not be_blank
      expect(asset.errors.details.keys).to eq(%i[mp3_content_type mp3])
    end
  end
end

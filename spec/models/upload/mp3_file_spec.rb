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
      expect(asset.name).to eq('�')
      expect(asset.mp3_file_name).to eq('�.mp3')
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

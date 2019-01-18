# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload::ZipFile, type: :model do
  let(:user) { users(:will_studd) }
  let(:zip_file_filename) { 'tracks.zip' }
  let(:asset_attributes) { nil }
  let(:playlist_attributes) { nil }
  let(:zip_file) do
    Upload::ZipFile.new(
      user: users(:will_studd),
      file: file_fixture_tempfile(zip_file_filename),
      asset_attributes: asset_attributes,
      playlist_attributes: playlist_attributes
    )
  end

  it 'processes' do
    expect(
      Upload::ZipFile.process(
        user: users(:will_studd),
        file: file_fixture_tempfile(zip_file_filename)
      )
    ).to be_kind_of(Upload::ZipFile)
  end

  context 'processing file with non-related MP3s' do
    it 'builds assets for all MP3 files and no playlist' do
      expect(zip_file.process).to eq(true)
      expect(zip_file.playlists).to be_empty

      expect(zip_file.assets.length).to eq(3)
      zip_file.assets.each do |asset|
        expect(asset.user).to eq(user)
        expect(asset.mp3_content_type).to eq('audio/mpeg')
        expect(asset.mp3_file_name).to_not be_empty
        expect(asset.private).to eq(false)
      end
    end
  end

  context 'processing file for an album' do
    let(:zip_file_filename) { 'Le Duc Vacherin.zip' }

    it 'builds assets for all MP3 files and a playlist' do
      expect(zip_file.process).to eq(true)

      expect(zip_file.playlists.length).to eq(1)
      playlist = zip_file.playlists.first
      expect(playlist.user).to eq(user)
      expect(playlist.title).to eq('Le Duc Vacherin')
      expect(playlist.private).to be_nil

      expect(zip_file.assets.length).to eq(3)
      zip_file.assets.each do |asset|
        expect(asset.user).to eq(user)
        expect(asset.mp3_content_type).to eq('audio/mpeg')
        expect(asset.mp3_file_name).to_not be_empty
        expect(asset.private).to eq(false)
      end
    end
  end

  context 'processing file with one usable and one unusable MP3' do
    let(:zip_file_filename) { '1valid-1invalid.zip' }

    it 'builds assets for all good MP3 files and no playlist' do
      expect(zip_file.process).to eq(false)

      expect(zip_file.playlists).to be_empty
      expect(zip_file.assets.length).to eq(2)

      usable = zip_file.assets.select(&:valid?)[0]
      expect(usable.user).to eq(user)
      expect(usable.mp3_content_type).to eq('audio/mpeg')
      expect(usable.mp3_file_name).to eq('muppets.mp3')
      expect(usable.errors).to be_empty

      unusable = zip_file.assets.reject(&:valid?)[0]
      expect(unusable.user).to eq(user)
      expect(unusable.mp3_content_type).to eq('inode/x-empty')
      expect(unusable.mp3_file_name).to eq('cavernous.mp3')
      expect(unusable.errors).to_not be_empty
    end
  end

  context 'processing file without any data' do
    let(:zip_file_filename) { 'smallest.zip' }

    it 'does not build assets nor playlists' do
      expect(zip_file.process).to eq(true)
      expect(zip_file.playlists).to be_empty
      expect(zip_file.assets).to be_empty
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
      expect(zip_file.process).to eq(true)
      expect(zip_file.playlists).to be_empty

      expect(zip_file.assets.length).to eq(3)
      zip_file.assets.each do |asset|
        expect(asset.private).to eq(true)
        expect(asset.user_agent).to eq(user_agent)
      end
    end
  end

  context 'processing with additional attributes for playlists' do
    let(:user_agent) do
      'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)'
    end
    let(:playlist_attributes) do
      {
        private: true,
        year: '2019'
      }
    end
    let(:zip_file_filename) { 'Le Duc Vacherin.zip' }

    it 'applies attributes to playlists it builds' do
      expect(zip_file.process).to eq(true)

      expect(zip_file.playlists.length).to eq(1)
      zip_file.playlists.each do |playlist|
        expect(playlist.private).to eq(true)
        expect(playlist.year).to eq('2019')
      end
    end
  end
end

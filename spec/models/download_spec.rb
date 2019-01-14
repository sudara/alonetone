# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Download, type: :model do
  let(:user) { users(:will_studd) }
  let(:asset_attributes) { nil }
  let(:playlist_attributes) { nil }
  let(:url) do
    'https://www.dropbox.com/sh/kjuwsu3t0bckys0/AAAShHNh-kmdaM_UgZIeWmQba' \
    '?dl=0&preview=Google+Hangouts+2017-07-21+20-37-44.mp3'
  end
  let(:stubbed_filename) { 'smallest.mp3' }
  let(:stubbed_file) do
    file_fixture_pathname(stubbed_filename).open(encoding: 'binary')
  end
  let(:download) do
    Download.new(
      user: user, url: url,
      asset_attributes: asset_attributes, playlist_attributes: playlist_attributes
    )
  end

  before do
    stub_request(
      :get, download.rewritten_url
    ).and_return(
      body: stubbed_file
    )
  end

  it 'processes' do
    expect(
      Download.process(
        user: users(:will_studd),
        url: url
      )
    ).to be_kind_of(Download)
  end

  context 'Dropbox URL to an MP3' do
    it 'uses the preview parameter as the original filename' do
      expect(download.original_filename).to eq('Google Hangouts 2017-07-21 20-37-44.mp3')
    end

    it 'rewrites the URL for direct download' do
      expect(download.rewritten_url).to eq(
        'https://www.dropbox.com/sh/kjuwsu3t0bckys0/AAAShHNh-kmdaM_UgZIeWmQba?' \
        'dl=1&preview=Google+Hangouts+2017-07-21+20-37-44.mp3'
      )
    end

    it 'processing builds a single asset and no playlists' do
      expect do
        expect do
          expect(download.process).to eq(true)
        end.to change { user.assets.count }.by(+1)
      end.to_not change { Playlist.count }

      expect(download.playlists.length).to eq(0)
      expect(download.assets.length).to eq(1)

      asset = download.assets[0]
      expect(asset.errors).to be_blank
      expect(asset.user).to eq(user)
      expect(asset.mp3_content_type).to eq('audio/mpeg')
      expect(asset.mp3_file_name).to eq(download.original_filename)
      expect(asset.mp3_file_size).to eq(72)
    end
  end

  context 'Dropbox URL to a ZIP file' do
    let(:url) do
      'https://www.dropbox.com/sh/kjuwsu3t0bckys0/AAAShHNh-kmdaM_UgZIeWmQba' \
      '?dl=0&preview=Le+Duc+Vacherin.zip'
    end
    let(:stubbed_filename) { 'Le Duc Vacherin.zip' }

    it 'uses the preview parameter as the original filename' do
      expect(download.original_filename).to eq('Le Duc Vacherin.zip')
    end

    # Disabled because the ZIP contains tracks with UTF-8 sequences not supported by the database
    # encoding.
    it 'processing builds a single asset and no playlists' do
      expect do
        expect do
          expect(download.process).to eq(true)
        end.to change { user.assets.count }.by(+3)
      end.to change { Playlist.count }.by(+1)

      expect(download.playlists.length).to eq(1)
      expect(download.assets.length).to eq(3)
    end
  end

  context 'Google Drive URL to a ZIP file without album' do
    let(:url) do
      'https://drive.google.com/file/d/0B1fSTDvJdRmYZV85SmtfZkI4Y2s/view?usp=sharing'
    end
    let(:stubbed_filename) { 'tracks.zip' }

    it 'uses the end of the request path as the original filename' do
      expect(download.original_filename).to eq('view.mp3')
    end

    it 'rewrites the URL for direct download' do
      expect(download.rewritten_url).to eq(
        'https://drive.google.com/uc?export=download&id=0B1fSTDvJdRmYZV85SmtfZkI4Y2s'
      )
    end

    it 'processing builds and asset and no playlists' do
      expect do
        expect do
          expect(download.process).to eq(true)
        end.to change { user.assets.count }.by(+3)
      end.to_not change { Playlist.count }

      expect(download.playlists.length).to eq(0)
      expect(download.assets.length).to eq(3)
    end
  end

  context 'any old URL to an MP3 with tags' do
    let(:url) do
      'http://example.com/download/' + stubbed_filename
    end
    let(:stubbed_filename) { 'piano.mp3' }

    it 'uses the end of the request path as the original filename' do
      expect(download.original_filename).to eq('piano.mp3')
    end

    it 'does not rewrite the URL' do
      expect(download.rewritten_url).to eq(url)
    end

    it 'processing builds an asset and no playlist' do
      expect do
        expect do
          expect(download.process).to eq(true)
        end.to change { user.assets.count }.by(1)
      end.to_not change { Playlist.count }

      expect(download.playlists.length).to eq(0)
      expect(download.assets.length).to eq(1)
    end
  end

  context 'with additional asset attributes' do
    let(:asset_attributes) do
      { private: true }
    end

    it 'applies attributes to assets it builds' do
      expect(download.process).to eq(true)
      expect(download.assets.length).to eq(1)
      download.assets.each do |asset|
        expect(asset.private).to eq(true)
      end
    end
  end

  context 'with additional playlist attributes' do
    let(:stubbed_filename) { 'Le Duc Vacherin.zip' }
    let(:playlist_attributes) do
      { year: '2019' }
    end

    it 'applies attributes to assets it builds' do
      expect(download.process).to eq(true)
      expect(download.playlists.length).to eq(1)
      download.playlists.each do |playlist|
        expect(playlist.year).to eq('2019')
      end
    end
  end
end

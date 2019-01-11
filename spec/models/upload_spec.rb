# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload, type: :model do
  let(:user) { users(:will_studd) }
  let(:uploaded_filename) { 'smallest.zip' }
  let(:uploaded_file) do
    ActionDispatch::Http::UploadedFile.new(
      tempfile: file_fixture_tempfile(uploaded_filename),
      filename: uploaded_filename,
      type: 'application/zip'
    )
  end
  let(:upload) do
    Upload.new(
      user: user,
      files: [uploaded_file]
    )
  end

  it 'processes' do
    expect(
      Upload.process(
        files: [uploaded_file],
        user: users(:will_studd)
      )
    ).to be_kind_of(Upload)
  end

  context 'blank' do
    let(:upload) { Upload.new }

    it 'does not process because no files were uploaded' do
      expect(upload.process).to eq(false)
      expect(upload.errors.details).to eq(
        files: [{ error: :blank }],
        user: [{ error: :blank }]
      )
    end
  end

  context 'with empty uploaded ZIP file' do
    it 'processes but does not create any assets not playlists' do
      expect do
        expect(upload.process).to eq(true)
      end.to_not change { Asset.count + Playlist.count }

      expect(upload.playlists).to be_empty
      expect(upload.assets).to be_empty
    end
  end

  context 'with uploaded ZIP file with separate tracks' do
    let(:uploaded_filename) { 'tracks.zip' }

    it 'processes and creates an asset for each MP3 and no playlist' do
      expect do
        expect do
          expect(upload.process).to eq(true)
        end.to change { user.assets.count }.by(+3)
      end.to_not change { Playlist.count }

      expect(upload.playlists.length).to eq(0)
      expect(upload.assets.length).to eq(3)
    end
  end

  context 'with ZIP' do
    let(:uploaded_filename) { '1valid-1invalid.zip' }

    it 'processes and creates an asset for each MP3 and no playlist' do
      expect do
        expect do
          expect(upload.process).to eq(true)
        end.to change { user.assets.count }.by(+1)
      end.to_not change { Playlist.count }

      expect(upload.playlists.length).to eq(0)
      expect(upload.assets.length).to eq(2)
      expect(upload.assets.reject(&:valid?).length).to eq(1)
    end
  end

  # Disabled because the ZIP contains tracks with UTF-8 sequences not supported by the database
  # encoding.
  context 'with uploaded ZIP file with tracks in same album' do
    let(:uploaded_filename) { 'Le Duc Vacherin.zip' }

    it 'processes and creates an asset for each MP3 and no playlist' do
      expect do
        expect do
          expect(upload.process).to eq(true)
        end.to change { user.assets.count }.by(+3)
      end.to change { Playlist.count }.by(+1)

      expect(upload.playlists.length).to eq(1)
      expect(upload.assets.length).to eq(3)
    end
  end

  context 'with multiple uploaded files' do
    let(:uploaded_filenames) do
      ['1valid-1invalid.zip', 'piano.mp3', 'smallest.mp3', 'broken.zip']
    end
    let(:uploaded_files) do
      uploaded_filenames.map do |uploaded_filename|
        ActionDispatch::Http::UploadedFile.new(
          tempfile: file_fixture_tempfile(uploaded_filename),
          filename: uploaded_filename,
          type: 'application/octet-stream'
        )
      end
    end
    let(:upload) do
      Upload.new(
        user: user,
        files: uploaded_files
      )
    end

    it 'processes and creates an asset for each MP3 and no playlist' do
      expect do
        expect do
          expect(upload.process).to eq(true)
        end.to change { user.assets.count }.by(+4)
      end.to_not change { Playlist.count }

      expect(upload.playlists.length).to eq(0)
      expect(upload.assets.length).to eq(5)
      expect(upload.assets.reject(&:valid?).length).to eq(1)
    end
  end
end

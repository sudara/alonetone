# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload, type: :model do
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
      files: [uploaded_file],
      user: users(:will_studd)
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

  context 'with blank uploaded ZIP file' do
    it 'processes' do
      expect(upload.process).to eq(true)
    end
  end

  context 'with uploaded ZIP file' do
    let(:uploaded_filename) { 'tracks.zip' }

    it 'processes' do
      expect(upload.process).to eq(true)
    end
  end

  context 'with multiple uploaded files' do
    let(:uploaded_filenames) { %w[tracks.zip smallest.mp3] }
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
        files: uploaded_files,
        user: users(:will_studd)
      )
    end

    it 'processes' do
      expect(upload.process).to eq(true)
    end
  end
end

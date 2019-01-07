# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload, type: :model do
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

  context 'with uploaded ZIP file' do
    let(:uploaded_file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: file_fixture_tempfile('smallest.zip'),
        filename: 'smallest.zip',
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
      expect(upload.process).to eq(true)
    end
  end
end

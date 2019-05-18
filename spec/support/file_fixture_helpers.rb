# frozen_string_literal: true

module RSpec
  module Support
    module FileFixtureHelpers
      def file_fixture(path)
        file_fixture_pathname(path).to_s
      end

      def file_fixture_pathname(path)
        ::Rails.root.join(file_fixture_path, path)
      end

      def file_fixture_tempfile(path)
        tempfile = Tempfile.open(encoding: 'binary')
        FileUtils.cp(file_fixture(path), tempfile.path)
        tempfile
      end

      def file_fixture_uploaded_file(path, filename: nil, content_type: nil)
        filename ||= File.basename(path)
        ActionDispatch::Http::UploadedFile.new(
          tempfile: file_fixture_tempfile(path),
          filename: filename,
          type: content_type || 'application/octet-stream'
        )
      end

      def file_fixture_asset(path, filename: nil, content_type: nil, user: nil)
        asset = process_file_fixture_uploaded_file(
          path, filename: filename, content_type: content_type, user: user
        )
        raise(
          ArgumentError,
          "Can't process file fixture at `#{file_fixture_pathname(path).to_s}'"
        ) if asset.nil?
        asset
      end

      private

      def process_file_fixture_uploaded_file(path, filename: nil, content_type: nil, user: nil)
        Upload.process(
          user: user || users(:sudara),
          files: [
            file_fixture_uploaded_file(path, filename: filename, content_type: content_type)
          ]
        ).assets.first
      end
    end
  end
end

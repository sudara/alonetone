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
    end
  end
end

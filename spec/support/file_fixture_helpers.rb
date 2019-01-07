# frozen_string_literal: true

module RSpec
  module Support
    module FileFixtureHelpers
      def file_fixture(path)
        ::Rails.root.join(file_fixture_path, path).to_s
      end

      def file_fixture_tempfile(path)
        tempfile = Tempfile.open(encoding: 'binary')
        FileUtils.cp(file_fixture(path), tempfile.path)
        tempfile
      end
    end
  end
end

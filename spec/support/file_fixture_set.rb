# frozen_string_literal: true

module RSpec
  module Support
    # Overrides the create_fixtures method to automatically create file fixtures for all
    # fixtures in active_storage/blobs.yml.
    module FileFixtureSet
      def file_fixture_matching_filename(fixtures_directory, filename)
        fixture_filename = File.join(fixtures_directory, filename)
        fixture_filename if File.exist?(fixture_filename)
      end

      def file_fixture_filename_matching_content_type(content_type)
        case content_type
        when 'audio/mpeg'
          'muppets.mp3'
        when 'image/jpeg'
          'cheshire_cheese.jpg'
        when 'image/png'
          'smallest.png'
        when 'application/zip'
          'smallest.zip'
        end
      end

      def file_fixture_matching_content_type(fixtures_directory, content_type)
        fixture_filename = file_fixture_filename_matching_content_type(content_type)
        File.join(fixtures_directory, fixture_filename) if fixture_filename
      end

      def file_fixture_matching_fixture(fixtures_directory, fixture)
        file_fixture_matching_filename(fixtures_directory, fixture['filename']) ||
          file_fixture_matching_content_type(fixtures_directory, fixture['content_type'])
      end

      def ensure_blob_on_disk(fixtures_directory, fixture, blob)
        return if blob.service.exist?(blob.key)

        fixture_filename = file_fixture_matching_fixture(fixtures_directory, fixture)
        if fixture_filename
          File.open(fixture_filename, 'rb') { |file| blob.upload(file) }
          blob.update_columns(
            checksum: Digest::MD5.file(fixture_filename).base64digest,
            byte_size: File.size(fixture_filename)
          )
        else
          raise(
            ArgumentError,
            "Don't know how to create a blob in Active Storage for the fixture `#{name}'."
          )
        end
      end

      def ensure_blobs_on_disk(fixtures_directory, blobs)
        fixtures_directory = File.join(fixtures_directory, 'files')
        blobs.fixtures.each do |name, fixture|
          ensure_blob_on_disk(fixtures_directory, fixture, blobs.model_class.find(fixture['id']))
        end
      end

      def create_fixtures_blobs(fixtures_directory, fixture_set_names, fixture_sets)
        if fixture_set_names.include?('active_storage/blobs')
          blobs = fixture_sets.find { |set| set.table_name == 'active_storage_blobs' }
          ensure_blobs_on_disk(fixtures_directory, blobs) if blobs
        end
        fixture_sets
      end

      def create_fixtures(fixtures_directory, fixture_set_names, class_names = {}, config = ActiveRecord::Base, &block)
        create_fixtures_blobs(fixtures_directory, fixture_set_names, super)
      end
    end
  end
end

require 'active_record/fixtures'

module ActiveRecord
  class FixtureSet
    class << self
      prepend RSpec::Support::FileFixtureSet
    end
  end
end

# frozen_string_literal: true

require 'zip'

class Upload
  # Service class to deal with audio files in a ZIP file.
  class ZipFile
    include ActiveModel::Model

    # File with the uploaded file data. Note that this may be a Tempfile
    # generated from a ZIP file so its path may have nothing to do with the
    # orignal filename,
    attr_accessor :file

    # The user who originate the upload.
    attr_accessor :user

    # Returns assets built for the ZIP.
    attr_reader :assets

    # Returns playlists built for the ZIP, usually this is one.
    attr_reader :playlists

    validates :file, :user, presence: true
    validates :assets, :playlists, each_valid: true

    def album_title
      album_title_from_assets || album_title_for_user
    end

    def process
      reset
      process_zip_entries
      build_playlists
      valid?
    end

    def reset
      @assets = []
      @playlists = []
    end

    def self.process(attributes)
      zip_file = new(attributes)
      zip_file.process
      zip_file
    end

    private

    def process_zip_entries
      ::Zip::File.open(file.path) do |zip|
        zip.each { |entry| process_entry(zip, entry) }
      end
    end

    def process_entry(zip, entry)
      basename = File.basename(entry.name.dup.force_encoding('utf-8'))

      # We only care about MP3
      return unless basename.ends_with?('.mp3')
      # And not resource forks or Linux hidden files.
      return if basename.start_with?('.')

      Tempfile.open(encoding: 'binary') do |tempfile|
        tempfile.write(zip.read(entry))
        tempfile.rewind
        mp3_file = Upload::Mp3File.new(
          user: user, file: tempfile, filename: basename
        )
        mp3_file.process
        @assets.concat(mp3_file.assets)
      end
    end

    def ordered_assets
      assets.sort_by(&:id3_track_num)
    end

    def assets_track_numbers
      Set.new(assets.map(&:id3_track_num))
    end

    def expected_assets_track_numbers
      Set.new((1..assets.size))
    end

    def album?
      return false if assets.empty?

      expected_assets_track_numbers == assets_track_numbers
    end

    def album_title_from_assets
      ordered_assets[0]&.album
    end

    def album_title_for_user
      "#{@user.name}'s New Album"
    end

    def build_playlists
      return unless album?

      playlist = Playlist.new(user: user, title: album_title)
      ordered_assets.each do |asset|
        playlist.tracks.build(user: user, playlist: playlist, asset: asset)
      end
      @playlists << playlist
    end
  end
end

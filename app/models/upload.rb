# frozen_string_literal: true

# Upload is a service class to deal with incoming uploads. It builds Assets
# and Playlists based on the uploaded files.
class Upload
  include ActiveModel::Model
  include ActiveModel::Validations

  # The uploaded file objects (i.e. ActionDispatch::Http::UploadedFile)
  attr_accessor :files

  # The user who initiated the upload.
  attr_accessor :user

  # Assets built based on the files uploaded.
  attr_reader :assets

  # Playlists built based on the files uploaded.
  attr_reader :playlists

  validates :files, :user, presence: true
  validates :assets, :playlists, each_valid: true

  def process
    process_files(self.class.mime_types(uploaded_files.map(&:path)))
    return false unless valid?

    @assets.each(&:save!)
    @playlists.each(&:save!)

    true
  end

  def uploaded_files
    files.blank? ? [] : files
  end

  def process_files(mime_types)
    reset
    uploaded_files.each do |uploaded_file|
      case mime_types[uploaded_file.path]
      when 'application/zip'
        zip_file = Upload::ZipFile.process(user: user, file: uploaded_file.tempfile)
        @assets.concat(zip_file.assets)
        @playlists.concat(zip_file.playlists)
      when 'audio/mpeg'
        mp3_file = Upload::Mp3File.process(
          user: user, file: uploaded_file.tempfile, filename: uploaded_file.original_filename
        )
        @assets.concat(mp3_file.assets)
      end
    end
  end

  def reset
    @assets = []
    @playlists = []
  end

  def self.mime_types(filenames)
    return {} if filenames.blank?

    Hash[
      `file --mime-type #{Shellwords.join(filenames)}`.split("\n").map do |line|
        line.split(': ', 2).map(&:strip)
      end
    ]
  end

  def self.process(attributes)
    upload = new(attributes)
    upload.process
    upload
  end
end

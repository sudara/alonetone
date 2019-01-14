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

  # Additional attributes to apply to assets.
  attr_accessor :asset_attributes

  # Additional attributes to apply to playlists.
  attr_accessor :playlist_attributes

  # Assets built based on the files uploaded.
  attr_reader :assets

  # Playlists built based on the files uploaded.
  attr_reader :playlists

  validates :files, :user, presence: true

  def process
    process_files(self.class.mime_types(uploaded_files.map(&:path)))
    return false unless valid?

    # Alonetone tries to import as much from any upload as possible and reports on things that went
    # wrong. This means we need to call save on all records built while processing files.
    @assets.each(&:save)
    @playlists.each(&:save)
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
        process_zip_file(uploaded_file)
      when 'audio/mpeg'
        process_mp3_file(uploaded_file)
      end
    end
  end

  def process_zip_file(uploaded_file)
    zip_file = Upload::ZipFile.process(
      user: user, file: uploaded_file.tempfile,
      asset_attributes: asset_attributes, playlist_attributes: playlist_attributes
    )
    @assets.concat(zip_file.assets)
    @playlists.concat(zip_file.playlists)
  end

  def process_mp3_file(uploaded_file)
    mp3_file = Upload::Mp3File.process(
      user: user, file: uploaded_file.tempfile, filename: uploaded_file.original_filename,
      asset_attributes: asset_attributes
    )
    @assets.concat(mp3_file.assets)
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

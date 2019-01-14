# frozen_string_literal: true

# Download is a service class to fetch a file from a public URL and then treat it as any other
# Upload.
class Download
  # Mimicks ActionDispatch::Http::UploadedFile so we can pass it into the Upload logic without
  # having to support two different interfaces.
  class DownloadedFile
    include ActiveModel::Model

    attr_accessor :tempfile
    attr_accessor :original_filename

    delegate :path, to: :tempfile
  end

  include ActiveModel::Model
  include ActiveModel::Validations

  # The URL to download as provided by the end-user.
  attr_reader :url

  # The URL to download without query parameters
  attr_reader :base_url

  # Query parameters of the download URL.
  attr_reader :query

  # Parsed query parameters
  attr_reader :params

  # The user who initiated the download.
  attr_accessor :user

  # Additional attributes to apply to assets.
  attr_accessor :asset_attributes

  # Additional attributes to apply to playlists.
  attr_accessor :playlist_attributes

  delegate :assets, to: :upload
  delegate :playlists, to: :upload

  validates :url, :user, presence: true

  def url=(url)
    @url = url
    @base_url, @query = url.split('?', 2)
    @params = Rack::Utils.parse_query(@query)
  end

  def uri
    @uri ||= URI.parse(rewritten_url)
  end

  def rewritten_url
    # Dropbox links contain a dl parameter which indicates whether to immediately start the
    # download. We want to change this to 1 to make sure it downloads.
    if base_url.include?('dropbox.com/sh') && params.key?('dl')
      base_url + '?' + Rack::Utils.build_query(params.merge('dl' => '1'))
    # Google Drive share URLs are completely different from the direct download URL, but we can
    # rewrite them pretty easily.
    elsif base_url.include?('drive.google.com/file/d')
      file_id = base_url.split('/')[5]
      'https://drive.google.com/uc?' + Rack::Utils.build_query(export: 'download', id: file_id)
    else
      url
    end
  end

  def original_filename
    dropbox_filename || filename_from_url
  end

  def process
    upload.process
  end

  private

  def file
    @file ||= begin
      file = Tempfile.open
      # rubocop:disable Security/Open
      IO.copy_stream(open(rewritten_url), file)
      # rubocop:enable Security/Open
      file.rewind
      file
    end
  end

  def dropbox_filename
    # The filename in Dropbox may be include in the `preview' parameter.
    params['preview']
  end

  def filename_from_url
    # Alonetone requires an MP3 file to _always_ end with `.mp3` or it migth not play right.
    File.basename(base_url, '.*') + '.mp3'
  end

  def downloaded_file
    Download::DownloadedFile.new(
      tempfile: file,
      original_filename: original_filename
    )
  end

  def upload
    @upload ||= Upload.new(
      user: user,
      files: [downloaded_file],
      asset_attributes: asset_attributes,
      playlist_attributes: playlist_attributes
    )
  end

  def self.process(attributes)
    download = new(attributes)
    download.process
    download
  end
end

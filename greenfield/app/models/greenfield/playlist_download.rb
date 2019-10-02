module Greenfield
  class PlaylistDownload < ActiveRecord::Base
    MAX_SIZE     = 2000.megabytes
    CONTENT_TYPE = ['application/zip', 'application/gzip'].freeze

    belongs_to :playlist
    has_one_attached :zip_file
  end
end

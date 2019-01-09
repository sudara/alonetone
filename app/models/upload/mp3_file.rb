# frozen_string_literal: true

class Upload
  # Service class to build Asset instances based on the MP3 data.
  class Mp3File
    include ActiveModel::Model

    # File with the uploaded file data. Note that this may be a Tempfile
    # generated from a ZIP file so its path may have nothing to do with the
    # orignal filename,
    attr_accessor :file

    # Filename belonging to the uploaded file data. This can be either the
    # original filename from the uploaded file or the name entry from a ZIP
    # file.
    attr_accessor :filename

    # The user who originate the upload.
    attr_accessor :user

    # Returns assets built for the MP3, usually this is one.
    attr_reader :assets

    validates :file, :filename, :user, presence: true
    validates :assets, each_valid: true

    def process
      reset
      @assets << Asset.new(user: user, mp3: file, mp3_file_name: filename)
      valid?
    end

    def reset
      @assets = []
    end

    def self.process(attributes)
      mp3_file = new(attributes)
      mp3_file.process
      mp3_file
    end
  end
end

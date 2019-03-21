# frozen_string_literal: true

require 'mp3info'
require 'paperclip'

module Paperclip
  # Processes incoming MP3 files and extracts ID3 information.
  class Mp3PaperclipProcessor < Processor
    ATTRIBUTE_TO_ID3_TAG_NAME = {
      album: 'album',
      artist: 'artist',
      bitrate: 'bitrate',
      length: 'length',
      samplerate: 'samplerate',
      title: 'title',
      id3_track_num: 'tracknum',
      genre: 'genre_s'
    }.freeze

    def make
      process_id3_tags
      File.open(@file.path, 'r', encoding: 'binary')
    end

    private

    def process_id3_tags
      ::Mp3Info.open(@file.path) { |info| copy_id3_tags_to_record(info) }
    rescue Mp3InfoError => error
      raise Paperclip::Error, "This doesn't look like an MP3 file (#{error.message})"
    end

    def copy_id3_tags_to_record(info)
      ATTRIBUTE_TO_ID3_TAG_NAME.each do |attribute_name, tag_name|
        value = info.respond_to?(tag_name) ? info.public_send(tag_name) : info.tag[tag_name]
        if value.respond_to?(:encode)
          value.encode(
            'UTF-8', invalid: :replace, undef: :replace, replace: "\ufffd"
          ).unicode_normalize(:nfkc)
        end
        attribute_writer = "#{attribute_name}="
        if attachment.instance.respond_to?(attribute_writer)
          attachment.instance.public_send(attribute_writer, value)
        end
      end
    end
  end
end

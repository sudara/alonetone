require 'mp3info'
require "paperclip"
module Paperclip
  class Mp3PaperclipProcessor < Processor
    # required method for the paperclip processor
    def make
      begin
        binary_data = ::Mp3Info.open(@file.path) do |mp3|
          write_meta_data_to_model(mp3)
        end
      rescue Mp3InfoError
        raise Paperclip::Error, "This doesn't look like an mp3 file"
      end
      File.open(@file.path, 'rb')
    end

    def write_meta_data_to_model(mp3)
      %w[samplerate bitrate length artist album].each do |simple_attribute|
        # copy the data out of the mp3
        @attachment.instance.send("#{simple_attribute}=", mp3.send(simple_attribute)) if @attachment.instance.respond_to?("#{simple_attribute}=") && mp3.respond_to?(simple_attribute)
      end
      @attachment.instance.title = get_title(mp3)
      @attachment.instance.id3_track_num = get_track_num(mp3)
      @attachment.instance.generate_permalink!
    end

    # title is a bit more complicated depending on tag type
    def get_title(mp3)
      if mp3.tag.title.present?
        mp3.tag.title.strip
      elsif mp3.tag2.TT2.present?
        mp3.tag2.TT2.strip
      end
    end

    def get_track_num(mp3)
      mp3.tag.tracknum
    end
  end
end

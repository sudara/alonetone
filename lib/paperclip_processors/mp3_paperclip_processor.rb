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
      @file
    end
    
    def write_meta_data_to_model(mp3)
      %w(samplerate bitrate length artist album).each do |simple_attribute|
        # copy the data out of the mp3 
        if @attachment.instance.respond_to?("#{simple_attribute}=") and mp3.respond_to?(simple_attribute)
          @attachment.instance.send("#{simple_attribute}=",mp3.send(simple_attribute))
        end
        @attachment.instance.title = set_title(mp3)
        @attachment.instance.generate_permalink!
      end
      @attachment.instance.waveform = get_waveform(mp3)
    end
    
    # title is a bit more complicated depending on tag type
    def set_title(mp3)
      if mp3.tag.title.present?
        mp3.tag.title.strip
      elsif mp3.tag2.TT2.present?
        mp3.tag2.TT2.strip 
      else
        nil
      end
    end

    def get_waveform(mp3)
      tmp = Tempfile.new(['resampled-upload', '.wav'])
      Paperclip.run(['ffmpeg', '-y', '-i', mp3.filename, '-af', 'aresample=10', tmp.path])

      waveform = []
      input = RubyAudio::Sound.open(tmp.path)
      begin
        until (signal = input.read(:int, 300).to_a).size.zero?
          signal.map!{ |s| Array(s).sum.to_f / s.size }
          waveform.concat(signal)
        end
      ensure
        input.close
        tmp.close!
      end

      waveform
    end
  end
end

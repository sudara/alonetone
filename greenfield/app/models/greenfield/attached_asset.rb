module Greenfield
  class AttachedAsset < ActiveRecord::Base
    belongs_to :post

    # TODO: Need to validate attachment embeds...

    attachment_options = {
      :styles => { :original => ''}, # just makes sure original runs through the processor
      :processors => [:mp3_paperclip_processor],
    }

    if Alonetone.storage == 's3'
      attachment_options[:path] = "/greenfield/:id/:basename.:extension" 
      attachment_options[:s3_permissions] = 'authenticated-read'
    end

    has_attached_file :mp3, attachment_options
    attr_accessible :mp3

    serialize :waveform, Array

    def extract_waveform(file)
      tmp = Tempfile.new(['resampled-upload', '.wav'])

      # resample the mp3 down to 8KHz to make it more manageable
      command = Paperclip.run(['lame', '--mp3input', '--resample', '8',
                               '--decode', Shellwords.shellescape(file),
                               Shellwords.shellescape(tmp.path)])

      # read in the data and make it mono
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

      # lame can only downsample to 8KHz, but that's still
      # way too high so we do a second resampling here
      waveform = waveform.each_slice(1000).map{ |slice| slice.sum.to_f / slice.size }

      self.waveform = waveform
    end

    attr_accessor :title
    def generate_permalink!; end
  end
end

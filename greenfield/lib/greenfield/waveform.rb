module Greenfield
  module Waveform
    def self.extract(file)
      tmp = Tempfile.new(['resampled-upload', '.wav'])

      # resample the mp3 down to 8KHz to make it more manageable
      begin
        command = Paperclip.run(['lame', '--mp3input', '--resample', '8',
                                 '--decode', Shellwords.shellescape(file),
                                 Shellwords.shellescape(tmp.path)])
      rescue Cocaine::ExitStatusError
        return nil
      end

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
      waveform.each_slice(1000).map{ |slice| slice.sum.to_f / slice.size }
    end
  end
end

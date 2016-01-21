module Greenfield
  module Waveform
    def self.extract(file)
      tmp = Tempfile.new(['resampled-upload', '.wav'])

      # resample the mp3 down to 8KHz to make it more manageable
      command = Paperclip.run(['lame', '--mp3input', '--resample', '8',
                               '--decode', Shellwords.shellescape(file),
                               Shellwords.shellescape(tmp.path)])

      # lame can only downsample to 8KHz, but that's still
      # way too high so we do a second resampling here
      # computing a RMS-like quantity over 500 slices
      waveform = []
      input = RubyAudio::Sound.open(tmp.path)
      begin
        rms = 0.0
        rms_size = islice = 0
        slice_size = input.info.frames / 500
        until (signal = input.read(:int, 300)).real_size.zero?
          signal.each do |frame|
            mono = frame.sum
            rms += mono * mono
          end

          rms_size += signal.real_size
          if rms_size > slice_size
            waveform << Math.sqrt(rms)
            rms = 0.0
            rms_size = 0
          end
        end
        waveform << Math.sqrt(rms)
      ensure
        input.close
        tmp.close!
      end

      waveform
    end
  end
end

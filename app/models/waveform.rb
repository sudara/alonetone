# Generates a list of RMS-like amplitudes which can be used to render a
# waveform for an MP3.
module Waveform
  def self.extract(file)
    Tempfile.open(['resampled-upload', '.wav']) do |tempfile|
      reduce_file(tempfile) if resample(file, tempfile)
    end
  end

  # Resample the source MP3 down to 8KHz to make it more manageable.
  def self.resample(file, tempfile)
    system(
      'lame',
      '--quiet',
      '--mp3input',
      '--resample', '8',
      '--decode', Shellwords.shellescape(file),
      Shellwords.shellescape(tempfile.path),
      out: File::NULL, err: File::NULL
    )
  end

  def self.reduce_file(tempfile)
    RubyAudio::Sound.open(tempfile.path) { |sound| reduce(sound) }
  rescue RubyAudio::Error
  end

  # Compute RMS-like values to reduce the number of slices to less than 500.
  def self.reduce(sound)
    waveform = []
    rms = 0.0
    rms_size = islice = 0
    slice_size = sound.info.frames / 500
    is_mono = sound.info.channels == 1
    until (signal = sound.read(:int, 300)).real_size.zero?
      signal.each do |frame|
        mono = is_mono ? frame : frame.sum
        rms += mono * mono
      end

      rms_size += signal.real_size
      next unless rms_size > slice_size

      waveform << Math.sqrt(rms).round
      rms = 0.0
      rms_size = 0
    end
    waveform << Math.sqrt(rms)
  end
end

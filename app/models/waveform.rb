# Generates a list of RMS-like amplitudes which can be used to render a
# waveform for an MP3.
module Waveform
  class Reduction
    attr_reader :sound
    attr_reader :slice_size

    def initialize(sound)
      @sound = sound
      self.info = sound.info
    end

    def mono?
      @mono
    end

    def samples
      samples = []
      while signal = read
        rms = 0.0
        for frame in signal
          rms += (mono? ? frame : frame.sum) ** 2
        end
        samples << Math.sqrt(rms).round
      end
      samples
    end

    private

    attr_reader :signal

    def info=(info)
      @mono = info.channels == 1
      @slice_size = (info.frames / 500.0).ceil
    end

    def read
      signal = sound.read(:int, slice_size)
      signal.real_size == 0 ? nil : signal
    end
  end

  def self.extract(file)
    Tempfile.open(['resampled-upload', '.wav']) do |tempfile|
      reduce_file(tempfile) if decode_resample(file, tempfile)
    end
  end

  # Resample the source MP3 down to 8KHz to make it more manageable.
  def self.decode_resample(file, tempfile)
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

  # Compute RMS-like values to reduce the number of aplitudes to 500.
  def self.reduce(sound)
    Waveform::Reduction.new(sound).samples
  end
end

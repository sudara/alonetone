# frozen_string_literal: true

# Generates a list of RMS-like amplitudes which can be used to render a waveform for an MP3.
class Waveform
  LENGTH = 500

  def initialize(path)
    @path = path
  end

  def extract
    return unless json

    # The audiowaveform tool doesn't allow us to restrict the number of samples that are created
    # so we need to resample to generate around 500 samples.
    rms = []
    slice_size = json.fetch('data').size.to_f / LENGTH
    json.fetch('data').each.with_index do |sample, index|
      bucket = index / slice_size
      rms[bucket] = rms[bucket].to_f + sample**2
    end
    return nil if rms.empty?

    rms.map { |sample| Math.sqrt(sample).round }
  end

  def self.extract(path)
    new(path).extract
  end

  private

  def json
    @json ||= execute
  end

  def execute
    json, status = Open3.capture2(
      'audiowaveform',
      '--input-filename', @path,
      # Uploaded audio is always converted to MP3 first because it needs to play in the browser.
      '--input-format', 'mp3',
      '--output-format', 'json',
      '--quiet'
    )
    JSON.load(json) if status.exitstatus == 0
  end
end

class Asset
  serialize :waveform, Array

  has_one :greenfield_post, class_name: '::Greenfield::Post'

  def import_waveform
    Tempfile.open(%w[mp3-download .mp3], encoding: 'binary') do |tempfile|
      audio_file.download { |chunk| tempfile.write(chunk) }
      update!(
        audio_feature_attributes: {
          waveform: Waveform.extract(tempfile.path)
        }
      )
    end
  end
end

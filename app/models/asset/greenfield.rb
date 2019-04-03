class Asset
  serialize :waveform, Array

  has_one :greenfield_post, class_name: '::Greenfield::Post'

  def import_waveform
    audio_file.open do |file|
      update!(
        audio_feature_attributes: { waveform: Waveform.extract(file.path) }
      )
    end
  end
end

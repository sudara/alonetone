class Asset
  serialize :waveform, Array

  has_one :greenfield_post, class_name: '::Greenfield::Post'

  def import_waveform
    Tempfile.open(%w[mp3-download .mp3]) do |tempfile|
      mp3.copy_to_local_file(:original, tempfile.path)
      update!(
        audio_feature_attributes: {
          waveform: Waveform.extract(tempfile.path)
        }
      )
    end
  end
end

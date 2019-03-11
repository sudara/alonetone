class Asset
  serialize :waveform, Array

  has_one :greenfield_post, class_name: '::Greenfield::Post'

  def import_waveform
    tmp = Tempfile.new(['mp3-download', '.mp3'])

    begin
      mp3.copy_to_local_file(:original, tmp.path)
      create_audio_feature!(waveform: Waveform.extract(tmp.path))
    ensure
      tmp.close!
    end
  end
end

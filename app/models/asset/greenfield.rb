class Asset
  serialize :waveform, Array
  attr_accessible :waveform

  has_one :greenfield_post, :class_name => '::Greenfield::Post'

  def import_waveform
    tmp = Tempfile.new(['mp3-download', '.mp3'])

    begin
      mp3.copy_to_local_file(:original, tmp.path)
      update!(:waveform => Greenfield::Waveform.extract(tmp.path))
    ensure
      tmp.close!
    end
  end
end

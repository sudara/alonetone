class Asset
  serialize :waveform, Array
  attr_accessible :waveform

  has_one :greenfield_post, :class_name => '::Greenfield::Post'

  def import_waveform
    tmp = Tempfile.new(['mp3-download', '.mp3'])

    begin
      url = mp3.expiring_url.gsub('s3.amazonaws.com/','')
      Paperclip.run(['curl', '-o', Shellwords.shellescape(tmp.path),
                     Shellwords.shellescape(url)])
      update_column(:waveform, Greenfield::Waveform.extract(tmp.path))
    ensure
      tmp.close!
    end
  end
end

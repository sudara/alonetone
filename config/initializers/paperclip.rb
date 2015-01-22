# Paperclip config, depends on yml loaded above
Paperclip::Attachment.default_options[:convert_options] = { :all => '-strip -colorspace RGB'}
Paperclip::Attachment.default_options[:storage] = Alonetone.storage

Paperclip::Attachment.default_options.merge!({ 
  :s3_credentials => {
    :access_key_id => Alonetone.amazon_id,
    :secret_access_key => Alonetone.amazon_key
  },
  :bucket => Alonetone.bucket,
  :s3_protocol => 'http',
  :s3_host_alias => Alonetone.bucket,
  :url => ':s3_alias_url',
  :s3_headers => { 'Expires' => 3.years.from_now.httpdate, 
    'Content-disposition' => 'attachment;'}
}) if Alonetone.storage == 's3'


require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end

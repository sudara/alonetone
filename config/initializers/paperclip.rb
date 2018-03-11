# Paperclip config, depends on yml loaded above
Paperclip::Attachment.default_options[:convert_options] = { :all => '-quality 82 -strip -colorspace RGB'}
Paperclip::Attachment.default_options[:storage] = Alonetone.storage

Paperclip::Attachment.default_options.merge!({
  :s3_credentials => {
    :access_key_id => Alonetone.amazon_id,
    :secret_access_key => Alonetone.amazon_key
  },
  :s3_region => 'us-east-1',
  :bucket => Alonetone.bucket,
  :s3_host_alias => Alonetone.s3_host_alias,
  :url => ':s3_alias_url',
  :s3_protocol => Alonetone.cloudfront_enabled ? :https : :http,
  :s3_url_options => {:virtual_host => true},
  :s3_headers => { 'Expires' => 3.years.from_now.httpdate,
    'Content-disposition' => 'attachment;'}
}) if Alonetone.storage == 's3'

Paperclip.interpolates :s3_path do |attachment, _|
  attachment.instance.s3_path
end

S3DirectUpload.config do |c|
  c.access_key_id =  Alonetone.amazon_id
  c.secret_access_key = Alonetone.amazon_key
  c.bucket = Alonetone.bucket
  c.url = "https://s3.amazonaws.com/#{Alonetone.bucket}"
end if Alonetone.storage == 's3'


require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end

Paperclip.options[:command_path] = "/usr/bin/" if Rails.env.production?

# Allow upload via URL
Paperclip::UriAdapter.register
# Paperclip config, depends on yml loaded above
Paperclip::Attachment.default_options[:convert_options] = { :all => '-quality 68 -strip -filter Triangle -define filter:support=2 -dither None -posterize 136 -colorspace sRGB -interlace none'}
Paperclip::Attachment.default_options[:storage] = Alonetone.storage_service

Paperclip::Attachment.default_options.merge!({
  :s3_credentials => {
    :access_key_id => Alonetone.amazon_access_key_id,
    :secret_access_key => Alonetone.amazon_secret_access_key
  },
  :s3_region => Alonetone.amazon_s3_region,
  :bucket => Alonetone.amazon_s3_bucket_name,
  :s3_host_alias => Alonetone.amazon_cloud_front_domain_name,
  :url => ':s3_alias_url',
  :s3_protocol => :https,
  :s3_url_options => {:virtual_host => true},
  :s3_headers => { 'Expires' => 3.years.from_now.httpdate,
    'Content-disposition' => 'attachment;'}
}) if Alonetone.storage_service == 's3'

Paperclip.interpolates :s3_path do |attachment, _|
  attachment.instance.s3_path
end

S3DirectUpload.config do |c|
  c.access_key_id =  Alonetone.amazon_access_key_id
  c.secret_access_key = Alonetone.amazon_secret_access_key
  c.bucket = Alonetone.amazon_s3_bucket_name
  c.url = "https://s3.amazonaws.com/#{Alonetone.amazon_s3_bucket_name}"
end if Alonetone.storage_service == 's3'

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
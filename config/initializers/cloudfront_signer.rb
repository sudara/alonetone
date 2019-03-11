Aws::CF::Signer.configure do |config|
  config.key_path = File.join(Rails.root,'config','certs','cloudfront.pem')
  config.key_pair_id = Rails.configuration.alonetone.amazon_cloud_front_key_pair_id
  config.default_expires = 3600
end if Rails.application.remote_storage?

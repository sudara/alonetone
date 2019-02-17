# frozen_string_literal: true

# Value class for the Alonetone configuration to help with changes to the
# application configuration file.
class Configurable
  UPGRADE = {
    'amazon_id' => 'amazon_access_key_id',
    'amazon_key' => 'amazon_secret_access_key',
    'bucket' => 'amazon_s3_bucket_name',
    'cloudfront_key_id' => 'amazon_cloud_front_key_pair_id',
    'ga' => 'google_analytics_tracking_id',
    'greenfield_url' => 'greenfield_hostname',
    'play_dummy_mp3s' => 'play_dummy_audio',
    's3_host_alias' => 'amazon_cloud_front_domain_name',
    'show_dummy_pics' => 'show_dummy_image',
    'storage' => 'storage_service',
    'typekit' => 'typekit_embed_token',
    'url' => 'hostname',
    'bugsnag_key' => 'bugsnag_api_key'
  }.freeze

  attr_accessor(
    :amazon_access_key_id,
    :amazon_cloud_front_domain_name,
    :amazon_cloud_front_key_pair_id,
    :amazon_s3_bucket_name,
    :amazon_s3_region,
    :amazon_secret_access_key,
    :bugsnag_api_key,
    :email,
    :google_analytics_tracking_id,
    :greenfield_hostname,
    :hostname,
    :play_dummy_audio,
    :rakismet_key,
    :secret,
    :show_dummy_image,
    :storage_service,
    :typekit_embed_token
  )

  attr_reader :environment
  attr_reader :upgraded
  attr_reader :deprecated

  def initialize(environment, attributes)
    @environment = environment
    @upgraded = {}
    @deprecated = []
    rewrite_attributes(attributes).each { |name, value| public_send("#{name}=", value) }
    print_upgrade_warning
  end

  def method_missing(method, *attributes, &block)
    if method.to_s.end_with?('=')
      name = method.to_s[0..-2]
      @deprecated << name
    else
      super
    end
  end

  def respond_to_missing?(method, _include_private)
    method.to_s.end_with?('=')
  end

  private

  def rewrite_attributes(attributes)
    attributes.each_with_object({}) do |(name, value), hash|
      if new_name = UPGRADE[name.to_s]
        @upgraded[name] = new_name
        hash[new_name] = value
      else
        hash[name] = value
      end
    end
  end

  def print_upgrade_warning
    return if deprecated.empty? && upgraded.empty?

    puts "[!] Please apply the following changes to `config/alonetone.yml' in #{environment}:"
    puts

    deprecated.each do |name|
      puts " * Remove #{name}"
    end

    upgraded.each do |name, new_name|
      puts " * Replace #{name} with #{new_name}"
    end
  end
end

# frozen_string_literal: true

module Configurable
  # Raised when not all required attributes are configured for the environment.
  class Error < RuntimeError; end

  ATTRIBUTES = %w[
    amazon_access_key_id
    amazon_cloud_front_domain_name
    amazon_cloud_front_key_pair_id
    amazon_s3_bucket_name
    amazon_s3_region
    amazon_secret_access_key
    email
    ga
    get_clicky
    greenfield_url
    play_dummy_mp3s
    rakismet_key
    secret
    storage_service
    typekit
    url
  ].freeze

  Configurable::ATTRIBUTES.each do |method_name|
    define_method(method_name) do
      Configurable.data[method_name]
    end
  end

  def storage
    ActiveSupport::StringInquirer.new(storage_service)
  end

  def cloudfront_enabled?
    return false unless storage.s3?

    amazon_cloud_front_domain_name.present?
  end

  def self.data
    @data ||= load_data
  end

  def self.relative_path
    'config/alonetone.yml'
  end

  def self.load_data
    data = YAML.load_file(Rails.root.join(relative_path))[Rails.env]
    unknown = data.keys - ATTRIBUTES
    unless unknown.empty?
      raise(
        Configurable::Error,
        "Configuration in `#{relative_path}' contains unknown configuration " \
        "keys: #{unknown.to_sentence}"
      )
    end
    missing = ATTRIBUTES - data.keys
    unless missing.empty?
      raise(
        Configurable::Error,
        "Configuration in `#{relative_path}' is missing required " \
        "configuration keys: #{missing.to_sentence}"
      )
    end
    data
  end
end

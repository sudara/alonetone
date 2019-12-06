# frozen_string_literal: true

module Storage
  # Generates an image URL to the Fastly service or Alonetone itself (useful for development).
  class FastlyLocation
    attr_reader :attachment

    def initialize(attachment)
      if attachment.blank?
        raise(
          ArgumentError,
          "Attachment can't be blank when creating a Storage::FastlyLocation."
        )
      end
      @attachment = attachment
    end

    def url
      params ? base_url + '?' + Rack::Utils.build_query(params) : base_url
    end

    alias to_s url

    def self.variation_params_for_operation(name, value)
      case name
      when :resize_to_fill
        {
          crop: '1:1', # All images on Alonetone are square
          width: value.first
        }
      when :saver
        { quality: value[:quality] }.compact
      else
        {}
      end
    end

    private

    delegate :transformations, to: "attachment.variation"

    def base_url_without_request_path
      if Rails.application.fastly_enabled?
        Rails.application.config.alonetone.fastly_base_url
      else
        'http://' + Rails.application.config.alonetone.hostname + '/thumbnails'
      end
    end

    def base_url
      base_url_without_request_path + request_path
    end

    def request_path
      '/' + attachment.blob.key
    end

    def params
      return nil unless attachment.respond_to?(:variation)

      variation_params
    end

    def variation_params
      transformations.each_with_object({}) do |(name, value), params|
        params.merge!(self.class.variation_params_for_operation(name, value))
      end
    end
  end
end

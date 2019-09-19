# frozen_string_literal: true

module Storage
  # Generates a public or signed URL to an uploaded file. Note that it behaves
  # like a promise so we can choose to delay evaluation until the URL should
  # actually be used in the view.
  class Location
    attr_reader :attachment

    def initialize(attachment, signed:)
      unless attachment
        raise(
          ArgumentError,
          "Attachment can't be blank when creating a Storage::Location."
        )
      end

      @attachment = attachment
      @signed = signed
    end

    def signed?
      !!@signed
    end

    def url
      if attachment.respond_to?(:processed)
        variant_url
      else
        original_url
      end
    end

    alias to_s url

    private

    def s3_object
      attachment.service.bucket.object(attachment.key)
    end

    def s3_url
      signed? ? s3_object.presigned_url(:get) : s3_object.public_url
    end

    # Returns a URL to either the processed image or a service URL to a service that will process
    # the image dynamicall.
    def variant_url
      if Rails.application.fastly_enabled?
        FastlyLocation.new(attachment).url
      else
        attachment.processed.service_url
      end
    end

    # Returns a URL to the unaltered original uploaded files.
    def original_url
      if Rails.application.cloudfront_enabled?
        CloudFrontLocation.new(attachment.key, signed: signed?).url
      elsif Rails.application.remote_storage?
        s3_url
      else
        attachment.service_url
      end
    end
  end
end

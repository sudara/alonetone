# frozen_string_literal: true

module Storage
  # Generates a public or signed URL to an S3 object through CloudFront. Note
  # that it behaves like a promise so we can choose to delay evaluation until
  # the URL should actually be used in the view.
  class CloudFrontLocation
    attr_reader :key

    def initialize(key, signed:)
      if key.blank?
        raise(
          ArgumentError,
          "Key can't be blank when creating a Storage::CloudFrontLocation."
        )
      end
      @key = key
      @signed = signed
    end

    def signed?
      !!@signed
    end

    def url
      signed? ? signed_url : public_url
    end

    alias to_s url

    def self.private_key_filename
      File.join(Rails.root, 'config', 'certs', 'cloudfront.pem')
    end

    def self.private_key
      # Read private key either from Configurable or disk depending on where
      # it was configured from.
      Rails.configuration.alonetone.amazon_cloud_front_private_key.presence ||
        File.read(private_key_filename)
    end

    def self.url_signer
      Aws::CloudFront::UrlSigner.new(
        key_pair_id: Rails.configuration.alonetone.amazon_cloud_front_key_pair_id,
        private_key: private_key
      )
    end

    private

    def signed_url
      self.class.url_signer.signed_url(
        public_url,
        expires: 20.minutes.from_now
      )
    end

    def public_url
      'https://' +
        Rails.configuration.alonetone.amazon_cloud_front_domain_name +
        '/' +
        key
    end
  end
end

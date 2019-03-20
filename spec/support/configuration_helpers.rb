# frozen_string_literal: true

module RSpec
  module Support
    module ConfigurationHelpers
      # Overrides a number of configuration variables for the duration of the
      # block.
      def with_alonetone_configuration(attributes)
        before = ::Rails.application.config.alonetone.dup
        begin
          ::Rails.application.config.alonetone.update(attributes)
          yield
        ensure
          ::Rails.application.config.alonetone = before
        end
      end

      # Returns random RSA private and public key in PEM format as string.
      def generate_amazon_cloud_front_private_key
        rsa = OpenSSL::PKey::RSA.new(2048)
        rsa.to_s + rsa.public_key.to_s
      end
    end
  end
end

# frozen_string_literal: true

module RSpec
  module Support
    module StorageServiceHelpers
      # Returns a new storage service instance so we can configure a global service.
      def storage_service(storage_service)
        ActiveStorage::Service.configure(
          storage_service, ::Rails.configuration.active_storage.service_configurations
        )
      end

      # Temporarily switches out the global storage service class.
      def with_storage_service(storage_service)
        before = ::Rails.application.config.active_storage.service
        service = ActiveStorage::Blob.service
        begin
          ::Rails.application.config.active_storage.service = storage_service
          ActiveStorage::Blob.service = storage_service(storage_service)
          yield
        ensure
          ::Rails.application.config.active_storage.service = before
          ActiveStorage::Blob.service = service
        end
      end

      # Rails 7.1 replaced ActiveStorage::Current.host with url_options. The
      # disk service builds URLs from these options, so we have to pass the
      # parsed pieces (protocol/host/port) rather than the raw base URL.
      def with_storage_current_host(base_url)
        uri = URI.parse(base_url)
        before = ActiveStorage::Current.url_options
        begin
          ActiveStorage::Current.url_options = {
            protocol: "#{uri.scheme}://",
            host: uri.host,
            port: uri.port
          }
          yield
        ensure
          ActiveStorage::Current.url_options = before
        end
      end
    end
  end
end

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
    end
  end
end

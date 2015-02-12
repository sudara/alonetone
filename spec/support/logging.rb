# Genius Level Thinking™ (and code) by Manfred Stienstra of fngtps
module RSpec
  module Support
    module Logging
      extend ActiveSupport::Concern

      module ClassMethods
        def spec_tagging
          before(:each) do |example|
            log_spec_start(title: example.full_description)
          end
          after(:each) do
            log_spec_end
          end
        end

        def debug_logging
          around(:each) do |example|
            before = ::Rails.logger.level
            begin
              ::Rails.logger.level = ::Logger::DEBUG
              example.run
            ensure
              ::Rails.logger.level = before
            end
          end
        end
      end

      def log_line(options={})
        char = options[:char] || '-'
        ::Rails.logger.debug(char * 80)
      end

      def log_spec_start(options={})
        ::Rails.logger.info("")
        log_line(char: '~')
        ::Rails.logger.info("** #{options[:title]}")
        log_line(char: '~')
      end

      def log_spec_end
        log_line(char: '~')
      end
    end
  end
end

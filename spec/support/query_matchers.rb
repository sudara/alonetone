# frozen_string_literal: true

module RSpec
  module Support
    module QueryMatchers
      class QueryCounter
        SHOW_MAX = 5

        def initialize(count:)
          @count = count
          @queries = []
          @semaphore = Mutex.new
        end

        def matches?(block)
          ActiveSupport::Notifications.subscribed(method(:callback), 'sql.active_record', &block)
          count == actual_count
        end

        def failure_message
          message = +"expected to execute #{count} queries, found: #{actual_count}"
          queries.first(SHOW_MAX).each { |query| message << "\n* #{query}"}
          if unshown_query_count > 0
            message << unshown_query_count_message
          end
          message
        end

        def supports_block_expectations?
          true
        end

        private

        attr_reader :count
        attr_reader :queries

        def actual_count
          @queries.length
        end

        def callback(_name, _start, _finish, _message_id, payload)
          @semaphore.synchronize do
            @queries << payload[:sql]
          end
        end

        def unshown_query_count
          actual_count - SHOW_MAX
        end

        def unshown_query_count_message
          "\n  ...and #{unshown_query_count} more " \
          "#{unshown_query_count == 1 ? 'query' : 'queries'}"
        end
      end

      # Checks the number of queries performed on the database.
      #
      # expect { code }.to perform_queries(count: 2)
      def perform_queries(count:)
        QueryCounter.new(count: count)
      end
    end
  end
end

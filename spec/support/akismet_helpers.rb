# frozen_string_literal: true

module RSpec
  module Support
    # WebMock helpers to quickly stub an Akismet response.
    module AkismetHelpers
      def akismet_url_expression(path)
        %r{https://\w+.rest.akismet.com/1.1/#{path}}
      end

      def akismet_stub_response_ham
        stub_request(
          :post, akismet_url_expression('comment-check')
        ).and_return(
          body: 'false'
        )
      end

      def akismet_stub_response_spam
        stub_request(
          :post, akismet_url_expression('comment-check')
        ).and_return(
          body: 'true'
        )
      end

      def akismet_stub_submit_ham
        stub_request(:post, akismet_url_expression('submit-ham'))
      end

      def akismet_stub_submit_spam
        stub_request(:post, akismet_url_expression('submit-spam'))
      end
    end
  end
end

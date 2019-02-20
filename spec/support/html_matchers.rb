# frozen_string_literal: true

module RSpec
  module Support
    module HTMLMatchers
      class MarkupMatcher
        TRUNCATE_AT = 25

        attr_reader :language, :query, :properties

        def initialize(options={})
          @language, @query, @properties =
            options[:language], options[:query], options[:properties]
        end

        def failure_message
          if matched_elements.empty?
            "expected `#{truncated_target}' to match #{language} `#{query}'"
          else
            "expected `#{truncated_target}' to match #{language} `#{query}' #{properties_explanation}"
          end + "\nmatched:\n\n" + matched_elements.to_s
        end

        def failure_message_when_negated
          unless matched_elements.empty?
            "expected: `#{truncated_target}' to NOT match #{language} `#{query}'"
          else
            "expected `#{truncated_target}' to NOT match #{language} `#{query}' #{properties_explanation}"
          end + "\nmatched:\n\n" + matched_elements.to_s
        end

        def matches?(target)
          @target = target
          matches_query?
        end

        # Specify how many times the query should match
        def times(count)
          properties[:times] = count
          self
        end

        def description
          "match_#{language} \"#{query}\""
        end

        private

        def truncated_target
          target = @target.to_s
          if target.length > TRUNCATE_AT
            target[0..TRUNCATE_AT].strip + '…'
          else
            target
          end
        end

        def pluralize_times(count)
          count.to_s + ' ' + (count == 1 ? 'time' : 'times')
        end

        def properties_explanation
          explanation = []
          if properties[:times]
            explanation << "#{pluralize_times(properties[:times])} (it matched #{pluralize_times(matched_elements.length)})"
          end
          explanation.join(' ')
        end

        def document
          if defined?(:Nokogiri)
            @document ||= Nokogiri::HTML.parse(@target.to_s)
          else
            raise RuntimeError, "Please add Nokogiri to your Gemfile to use the CSS or Xpath matchers"
          end
        end

        def matched_elements
          @matched_elements ||= begin
            case language
            when :css
              document.css(query)
            when :xpath
              document.xpath(query)
            end
          end
        end

        def matches_properties?
          if properties[:times]
            if matched_elements.length != properties[:times]
              return false
            end
          end
          true
        end

        def matches_query?
          !matched_elements.empty? && matches_properties?
        end
      end

      # Returns a matches which checks if the XPath query matches any
      # elements. Additional properties can be asserted with either extra
      # methods calls to the matcher or by specifying them as options.
      #
      #     expect('<html></html>').to match_xpath('/html')
      #     expect('<html><b></b><b></b></root>').to match_xpath('/html/b').times(2)
      def match_xpath(query, properties={})
        MarkupMatcher.new(language: :xpath, query: query, properties: properties)
      end

      # Returns a matches which checks if the CSS query matches any
      # elements. Additional properties can be asserted with either extra
      # methods calls to the matcher or by specifying them as options.
      #
      #     expect('<html></html>').to match_css('html')
      #     expect('<html><b></b><b></b></root>').to match_css('html b').times(2)
      def match_css(query, properties={})
        MarkupMatcher.new(language: :css, query: query, properties: properties)
      end
    end
  end
end

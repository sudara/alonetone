require 'pagy'

Pagy::OPTIONS.freeze

# Pagy 43 builds URLs from request.params in insertion order; v9 and earlier
# routed through Rails url_for, which alphabetizes via Hash#to_query. Keep that
# ordering so existing pagination URLs (and their SEO/canonical references) stay byte-stable.
class Pagy
  module Linkable
    def compose_url(absolute, path, params, fragment)
      query_string = QueryUtils.build_nested_query(params.sort.to_h).sub(/\A(?=.)/, '?')
      "#{@request.base_url if absolute}#{path || @request.path}#{query_string}#{fragment}"
    end
  end
end

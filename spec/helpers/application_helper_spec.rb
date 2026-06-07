# frozen_string_literal: true

require "rails_helper"

# Pagy autoloads Pagy::Request lazily on first real paginated request; load it
# explicitly so these specs pass in isolation, not just after the full suite warms it.
require "pagy/classes/request"

RSpec.describe ApplicationHelper, type: :helper do
  it "makes sure links are nofollow/ugc" do
    expect(nofollowize('<a href="hey">')).to eql('<a rel="nofollow ugc" href="hey">')
  end

  it "converts track descriptions to markdown" do
    expect(format_track_description("hey")).to eql("<p>hey</p>\n")
  end

  it "renders nofollow links in track descriptions" do
    expect(format_track_description("https://alonetone.com")).to eql("<p><a rel=\"nofollow ugc\" href=\"https://alonetone.com\">https://alonetone.com</a></p>\n")
  end

  it "renders hard breaks in track descriptions" do
    expect(format_track_description("this\nis\npoetry")).to eql("<p>this<br />\nis<br />\npoetry</p>\n")
  end

  it "combines smart punctuation, autolinks, and hard breaks in track descriptions" do
    input = "check out \"this\"\nhttps://alonetone.com"
    expect(format_track_description(input)).to eql(
      "<p>check out “this”<br />\n<a rel=\"nofollow ugc\" href=\"https://alonetone.com\">https://alonetone.com</a></p>\n"
    )
  end

  describe "Pagy URL generation" do
    # These URLs are public and indexed by search engines. Our initializer overrides
    # Pagy::Linkable#compose_url to alphabetize query params — matching the byte-stable
    # output Rails url_for produced under pagy 6/9. Changing these expectations means
    # changing canonical URLs.

    def make_pagy(path:, query: "", page: 1, **opts)
      params  = Rack::Utils.parse_nested_query(query)
      options = { count: 100, limit: 10, page: page,
                  request: { base_url: "http://alonetone.com", path: path, params: params, cookie: nil } }
      options.merge!(opts)
      options[:request] = Pagy::Request.new(options)
      Pagy::Offset.new(**options)
    end

    it "swaps the page key while preserving other query params, alphabetically" do
      pagy = make_pagy(path: "/", query: "query=hello")
      expect(pagy.page_url(3)).to eql("/?page=3&query=hello")
    end

    it "honors a custom page_key" do
      pagy = make_pagy(path: "/sudara/listens", page_key: 'listens_page')
      expect(pagy.page_url(2)).to eql("/sudara/listens?listens_page=2")
    end

    it "produces an absolute URL when :absolute is set" do
      pagy = make_pagy(path: "/", query: "query=hello")
      expect(pagy.page_url(2, absolute: true)).to eql("http://alonetone.com/?page=2&query=hello")
    end

    it "appends a fragment when given" do
      pagy = make_pagy(path: "/", query: "query=hello")
      expect(pagy.page_url(2, fragment: "tracks")).to eql("/?page=2&query=hello#tracks")
    end

    it "produces v9-parity URLs for the search_controller case" do
      # /search/:query routes to search#index with `query` as a *path* segment, not a query string.
      # Both v9 (via Rails url_for) and v43 (via our compose_url override) produced /search/foo?page=N.
      pagy = make_pagy(path: "/search/foo")
      expect(pagy.page_url(2)).to eql("/search/foo?page=2")
      expect(pagy.page_url(7)).to eql("/search/foo?page=7")
    end
  end
end

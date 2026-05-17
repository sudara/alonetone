# frozen_string_literal: true

require "rails_helper"

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

  describe "#pagy_url_for" do
    # Pinned to v6's url_for output: Rails alphabetizes query params via Hash#to_query.
    # Changing these expectations means changing public URLs — coordinate with SEO/canonicals.
    before do
      helper.request.path_parameters = { controller: 'assets', action: 'latest' }
      helper.request.query_string = "query=hello"
    end

    it "swaps the page param while preserving other query params" do
      pagy = Pagy.new(count: 100, limit: 10, page: 1)
      expect(helper.pagy_url_for(pagy, 3)).to eql("/?page=3&query=hello")
    end

    it "honors a custom page_param" do
      pagy = Pagy.new(count: 100, limit: 10, page: 1, page_param: :listens_page)
      expect(helper.pagy_url_for(pagy, 2)).to eql("/?listens_page=2&query=hello")
    end

    it "applies pagy.vars[:params] when given as a Proc" do
      pagy = Pagy.new(count: 100, limit: 10, page: 1, params: ->(p) { p.except("query") })
      expect(helper.pagy_url_for(pagy, 2)).to eql("/?page=2")
    end

    it "produces an absolute URL when absolute: true" do
      pagy = Pagy.new(count: 100, limit: 10, page: 1)
      expect(helper.pagy_url_for(pagy, 2, absolute: true)).to match(%r{\Ahttp://[^/]+/\?page=2&query=hello\z})
    end

    it "appends a fragment when given" do
      pagy = Pagy.new(count: 100, limit: 10, page: 1)
      expect(helper.pagy_url_for(pagy, 2, fragment: "#tracks")).to eql("/?page=2&query=hello#tracks")
    end

    it "produces identical URLs to the pre-bump v6 helper for the search_controller case" do
      # search_controller passes params: { query: @query }; the same @query is already in
      # request.query_parameters, so the Hash-merge branch is a no-op vs. v6's behavior.
      helper.request.path_parameters = { controller: 'search', action: 'index' }
      helper.request.query_string = "query=foo"

      v6 = ->(pagy, page) {
        params = helper.request.query_parameters.merge(pagy.vars[:page_param] => page, only_path: true)
        helper.url_for(params)
      }
      pagy = Pagy.new(count: 100, limit: 15, page: 1, params: { query: "foo" })

      expect(helper.pagy_url_for(pagy, 2)).to eql(v6.call(pagy, 2))
      expect(helper.pagy_url_for(pagy, 7)).to eql(v6.call(pagy, 7))
    end
  end
end

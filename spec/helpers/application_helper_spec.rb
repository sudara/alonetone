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
end

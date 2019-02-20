# frozen_string_literal: true

require "rails_helper"

RSpec.describe Test::FilesController, type: :request do
  let(:pic_url) { pics(:sudara_avatar).url(variant: :large) }

  it "serves a mock image for an existing Pic" do
    get pic_url
    expect(response).to be_successful
  end

  it "does not serve a mock image for non-existant Pic" do
    get pic_url.gsub('jpg', 'png')
    expect(response).to_not be_successful
  end

  it "does not serve unknown resources" do
    get '/system/unknown'
    expect(response).to_not be_successful
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pic, type: :model do
  context "valid and pointing to a file" do
    let(:pic) { pics(:sudara_avatar) }

    it "knows there is an image present" do
      expect(pic.image_present?).to eq(true)
    end

    it "returns a URL to a variant" do
      url = pic.url(variant: :album)
      expect(url).to start_with('/system/pics')
      expect(url).to end_with('.jpg')
    end
  end

  context "with missing information" do
    let(:pic) { pics(:orphan) }

    it "knows there is no image present" do
      expect(pic.image_present?).to eq(false)
    end

    it "does not return a URL" do 
      expect(pic.url(variant: :album)).to be_nil
    end
  end

  context "new record" do
    let(:pic) { Pic.new }

    it "knows there is no image present" do
      expect(pic.image_present?).to eq(false)
    end

    it "does not return a URL" do
      expect(pic.url(variant: :album)).to be_nil
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::FastlyLocation, type: :model do
  let(:location) { Storage::FastlyLocation.new(attachment) }
  let(:fastly_base_url) { 'https://fastly.example.com/images' }

  around do |example|
    with_alonetone_configuration(
      fastly_base_url: fastly_base_url
    ) do
      example.call
    end
  end

  it "does not initialize without an attachment" do
    expect do
      Storage::FastlyLocation.new(nil)
    end.to raise_error(ArgumentError)
  end

  context "when attachment is an image variant" do
    let(:avatar_image) { users(:henri_willig).avatar_image }
    let(:attachment) { ImageVariant.variant(avatar_image, variant: :original) }

    it "generates a URL to the image with Image Optimization params" do
      expect(location.to_s).to eq(
        "#{fastly_base_url}/#{attachment.blob.key}?crop=1%3A1&width=800" \
        "&quality=68"
      )
    end
  end

  context "when attachment is the originally uploaded image" do
    let(:avatar_image) { users(:henri_willig).avatar_image }
    let(:attachment) { avatar_image }

    it "generates a URL to the image" do
      expect(location.to_s).to eq(
        "#{fastly_base_url}/#{attachment.blob.key}"
      )
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImageVariant, type: :model do
  it "returns dimensions to use when resizing image variant" do
    expect(ImageVariant.resize_to_limit(:small)).to eq([50, 50])
    expect(ImageVariant.resize_to_limit(:greenfield)).to eq([1500, 1500])
  end

  it "verifies known variants" do
    expect do
      ImageVariant.verify(:large)
    end.to_not raise_error
  end

  it "raises an exception verifying unknown variants" do
    expect do
      ImageVariant.verify(:unknown)
    end.to raise_error(ArgumentError)
  end

  context "with uploaded attachment" do
    let(:attachment) do
      playlists(:will_studd_rockfort).cover_image
    end

    before do
      file_fixture_pathname('blue_de_bresse.jpg').open do |file|
        attachment.upload(file)
      end
    end

    it "returns a single image variant instance" do
      image_variant = ImageVariant.new(attachment, variant: :greenfield)
      expect(image_variant.attachment).to eq(attachment)
      expect(image_variant.variant_name).to eq(:greenfield)
      expect(image_variant.resize_to_limit).to eq([1500, 1500])
    end

    it "does not set ACL on S3 object when using file storage" do
      image_variant = ImageVariant.new(attachment, variant: :greenfield)
      expect(image_variant.process).to be_kind_of(ActiveStorage::Variant)
    end

    it "sets the correct ACL for the S3 object when using S3 storage" do
      image_variant = ImageVariant.new(attachment, variant: :greenfield)

      # Read details about the storage object.
      stub_request(
        :head,
        %r{https://.*\.amazonaws.com/#{image_variant.to_active_storage_variant.key}}
      )
      # Set the ACL on the storage object.
      stub_request(
        :put,
        %r{https://.*\.amazonaws.com/#{image_variant.to_active_storage_variant.key}}
      ).with(
        headers: { 'X-Amz-Acl' => 'public-read' }
      )

      with_storage_service('s3') do
        expect(image_variant.process).to be_kind_of(ActiveStorage::Variant)
      end
    end

    it "raises exception when trying to instantiate variant for nonexistent variant name" do
      expect do
        ImageVariant.new(attachment, variant: :unknown)
      end.to raise_error(ArgumentError)
    end

    it "returns a single active storage variant" do
      variant = ImageVariant.variant(attachment, variant: :greenfield)
      expect(variant).to be_kind_of(ActiveStorage::Variant)
    end

    it "raises exception when trying to get storage variant for nonexistent variant name" do
      expect do
        ImageVariant.variant(attachment, variant: :unknown)
      end.to raise_error(ArgumentError)
    end

    it "processes all variants for an attachment" do
      processed = ImageVariant.process(attachment)
      expect(processed.size).to eq(ImageVariant::VARIANTS.size)
      processed.each do |variant|
        expect(variant).to be_kind_of(ActiveStorage::Variant)
      end
    end
  end
end

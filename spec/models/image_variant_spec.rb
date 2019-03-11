# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImageVariant, type: :model do
  it "returns dimensions to use when fitting image variant" do
    expect(ImageVariant.resize_to_fit(:small)).to eq([50, 50])
    expect(ImageVariant.resize_to_fit(:greenfield)).to eq([1500, 1500])
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
end

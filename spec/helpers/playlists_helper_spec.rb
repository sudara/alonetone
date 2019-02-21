# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaylistsHelper, type: :helper do
  def white_theme_enabled?
    @white_theme_enable
  end

  it "downgrades original variant to album for ancient covers" do
    [1, 69806].each do |pic_id|
      expect(
        downgrade_variant(pic_id, variant: :original)
      ).to eq(:album)
    end
  end

  it "downgrades greenfield variant to album for ancient covers" do
    [1, 69806].each do |pic_id|
      expect(
        downgrade_variant(pic_id, variant: :greenfield)
      ).to eq(:album)
    end
  end

  it "does not downgrade album variant for ancient covers" do
    expect(downgrade_variant(1, variant: :album)).to eq(:album)
  end

  it "downgrades greenfield variant to original for old covers" do
    [69807, 72848].each do |pic_id|
      expect(
        downgrade_variant(pic_id, variant: :greenfield)
      ).to eq(:original)
    end
  end

  it "does not downgrade original variant for old covers" do
    expect(downgrade_variant(69807, variant: :original)).to eq(:original)
  end

  it "does not downgrade variants for current covers" do
    [72849, 3452345345].each do |pic_id|
      expect(
        downgrade_variant(pic_id, variant: :greenfield)
      ).to eq(:greenfield)
    end
  end
end

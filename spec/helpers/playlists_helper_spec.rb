# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaylistsHelper, type: :helper do
  def white_theme_enabled?
    @white_theme_enable
  end

  it "generates a div which is filled by the JavaScript with generated cover" do
    element = playlist_cover_div
    expect(element).to match_css('div[class]')
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

  it "returns a default dark cover URL" do
    [:small, :large, :album, :greenfield].each do |variant|
      url = dark_default_cover_url(variant: variant)
      expect(url).to start_with('/images/default/no-cover')
      expect(url).to end_with('.jpg')
    end
  end

  context "playlist with a cover" do
    let(:playlist) { playlists(:will_studd_rockfort) }

    it "formats a cover URL" do
      [:large, :album, :greenfield].each do |variant|
        url = playlist_cover_url(playlist, variant: variant)
        expect(url).to start_with('/system/pics')
        expect(url).to end_with('.jpg')
      end
    end

    it "downgrades the cover URL for older covers" do
      # Pretend this is an old pic
      playlist.pic.id = 1

      url = playlist_cover_url(playlist, variant: :greenfield)
      expect(url).to start_with('/system/pics')
      expect(url).to end_with('.jpg')
      expect(url).to include('album')
    end

    it "formats an image element with the cover" do
      element = playlist_cover_image(playlist, variant: :greenfield)
      expect(element).to match_css('img[src][alt="Playlist cover"]')
      expect(element).to include(playlist_cover_url(playlist, variant: :greenfield))
    end

    it "formats an image for the cover element" do
      element = playlist_cover(playlist, variant: :greenfield)
      expect(element).to match_css('img')
    end
  end

  context "playlist without a cover" do
    let(:playlist) { playlists(:henri_willig_polderkaas) }

    it "does not format a cover URL" do
      [:large, :album, :greenfield].each do |variant|
        expect(playlist_cover_url(playlist, variant: variant)).to be_nil
      end
    end

    it "raises exception when trying to create a cover image" do
      expect do
        playlist_cover_image(playlist, variant: :greenfield)
      end.to raise_error(ArgumentError)
    end

    it "formats a div for the cover element" do
      element = playlist_cover(playlist, variant: :greenfield)
      expect(element).to match_css('div')
    end
  end
end

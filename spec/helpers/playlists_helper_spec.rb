# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlaylistsHelper, type: :helper do
  def white_theme_enabled?
    @white_theme_enable
  end

  it 'generates a div which is filled by the JavaScript with generated cover' do
    element = playlist_cover_div
    expect(element).to match_css('div[class]')
  end

  it 'returns a default dark cover URL' do
    %i[small large album greenfield].each do |variant|
      url = dark_default_cover_url(variant: variant)
      expect(url).to start_with('/images/default/no-cover')
      expect(url).to end_with('.jpg')
    end
  end

  context 'playlist with an ancient cover' do
    let(:playlist) { playlists(:william_shatners_favorites) }

    it 'downgrades greenfield variant to album' do
      expect(
        downgrade_variant(playlist, variant: :greenfield)
      ).to eq(:album)
    end

    it 'downgrades original variant to album' do
      expect(
        downgrade_variant(playlist, variant: :original)
      ).to eq(:album)
    end

    it 'does not downgrade album variant' do
      expect(
        downgrade_variant(playlist, variant: :album)
      ).to eq(:album)
    end
  end

  context 'playlist with a legacy cover' do
    let(:playlist) { playlists(:jamie_kiesl_loves) }

    it 'downgrades greenfield variant to original' do
      expect(
        downgrade_variant(playlist, variant: :greenfield)
      ).to eq(:original)
    end

    it 'does not downgrade original variant' do
      expect(
        downgrade_variant(playlist, variant: :original)
      ).to eq(:original)
    end

    it 'does not downgrade album variant' do
      expect(
        downgrade_variant(playlist, variant: :album)
      ).to eq(:album)
    end
  end

  context 'playlist with a cover' do
    let(:playlist) { playlists(:will_studd_rockfort) }
    let(:base_url) { 'http://alonetone.example.com' }

    around do |example|
      with_storage_current_host(base_url) do
        example.call
      end
    end

    it 'formats a cover URL' do
      %i[large album greenfield].each do |variant|
        url = playlist_cover_url(playlist, variant: variant)
        expect(url).to start_with('http://')
        expect(url).to end_with('.jpg')
      end
    end

    it 'downgrades the cover URL for ancient covers' do
      playlist.cover_quality = :ancient

      url = playlist_cover_url(playlist, variant: :greenfield)
      expect(url).to start_with('http://alonetone.example.com')
      expect(url).to end_with('.jpg')
    end

    it 'formats an image element with the cover' do
      element = playlist_cover_image(playlist, variant: :greenfield)
      expect(element).to match_css('img[src][alt="Playlist cover"]')
      expect(element).to include(base_url)
    end

    it 'formats an image for the cover element' do
      element = playlist_cover(playlist, variant: :greenfield)
      expect(element).to match_css('img')
    end

    it 'formats a URL to the dark playlist cover' do
      # Singed URLs to active storage disk controller intentionally doesn't
      # expose any information about the URL we just built.
      expect(
        dark_playlist_cover_url(playlist, variant: :large)
      ).to start_with('http://alonetone.example.com')
    end
  end

  context 'playlist without a cover' do
    let(:playlist) { playlists(:henri_willig_polderkaas) }

    it 'does not format a cover URL' do
      %i[large album greenfield].each do |variant|
        expect(playlist_cover_url(playlist, variant: variant)).to be_nil
      end
    end

    it 'raises exception when trying to create a cover image' do
      expect do
        playlist_cover_image(playlist, variant: :greenfield)
      end.to raise_error(ArgumentError)
    end

    it 'formats a div for the cover element' do
      element = playlist_cover(playlist, variant: :greenfield)
      expect(element).to match_css('div')
    end

    it 'formats a URL to the dark playlist default cover' do
      expect(
        dark_playlist_cover_url(playlist, variant: :large)
      ).to eq(dark_default_cover_url(variant: :large))
    end
  end
end

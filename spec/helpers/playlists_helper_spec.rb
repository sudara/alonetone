# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlaylistsHelper, type: :helper do

  it 'generates a div which is filled by the JavaScript with generated cover' do
    element = playlist_cover_div
    expect(element).to match_css('div[class]')
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
      %i[playlist_card playlist_cover].each do |variant|
        url = playlist_cover_url(playlist, variant: variant)
        expect(url).to start_with(base_url)
      end
    end

    it 'downgrades the cover URL for ancient covers' do
      playlist.cover_quality = :ancient
      url = playlist_cover_url(playlist, variant: :greenfield)
      expect(url).to start_with(base_url)
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
  end
end

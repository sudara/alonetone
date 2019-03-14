module Greenfield
  class Playlist
    delegate :to_param, :title, :user, :cover_url, :credits,
             :link1, :link2, :link3, :has_details?,
             to: :alonetone_playlist

    def initialize(alonetone_playlist)
      @alonetone_playlist = alonetone_playlist
    end

    def tracks
      alonetone_playlist.tracks.joins(asset: :greenfield_post)
    end

    def downloads
      alonetone_playlist.greenfield_downloads
    end

    private

    attr_reader :alonetone_playlist
  end
end

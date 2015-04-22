module Greenfield
  class Playlist
    attr_reader :alonetone_playlist

    delegate :to_param, to: :alonetone_playlist

    def initialize(alonetone_playlist)
      @alonetone_playlist = alonetone_playlist
    end

    def tracks
      alonetone_playlist.tracks.joins(asset: :greenfield_post)
    end
  end
end

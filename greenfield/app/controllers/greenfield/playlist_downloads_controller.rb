module Greenfield
  class PlaylistDownloadsController < Greenfield::ApplicationController
    include Listens

    before_action :prevent_abuse

    def serve
      alonetone_playlist = ::Playlist.find_by!(permalink: params[:playlist_id])
      download = alonetone_playlist.greenfield_downloads.find(params[:download_id])

      Greenfield::PlaylistDownload.increment_counter(:serves, download.id)
      redirect_to download.url
    end

    protected

    def prevent_abuse
      if is_a_bot?
        render(:text => "Denied due to abuse", :status => 403)
      end
    end
  end
end

class PlaylistDownloadsController < ApplicationController
  include Listens

  before_action :prevent_abuse

  def serve
    playlist = Playlist.find_by!(permalink: params[:playlist_id])
    download = playlist.greenfield_downloads.find(params[:download_id])

    PlaylistDownload.increment_counter(:serves, download.id)
    redirect_to download.url
  end

  protected

  def prevent_abuse
    if is_a_bot?
      render(:text => "Denied due to abuse", :status => 403)
    end
  end
end
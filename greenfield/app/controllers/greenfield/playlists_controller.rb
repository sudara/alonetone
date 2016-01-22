module Greenfield
  class PlaylistsController < Greenfield::ApplicationController
    include Listens

    def show
      @post = find_asset.try(:greenfield_post)
      respond_to do |format|
        format.html do
          @page_title = "#{@playlist.user.display_name} - #{@playlist.title}"
        end

        format.mp3 do
          listen(@post.asset, register: false)
        end
      end
    end


    protected

    def find_asset
      @alonetone_playlist = ::Playlist.find_by!(permalink: params[:playlist_id])
      @playlist ||= Greenfield::Playlist.new(@alonetone_playlist)
      if params[:asset_id].present?
        @asset ||= Asset.where(id: @playlist.tracks.pluck(:asset_id), permalink: params[:asset_id]).take!
      end
    end

    def require_login
      if find_post.user != current_user
        flash[:message] = "You'll need to login to do that"
        super(find_post.user)
      end
    end
  end
end

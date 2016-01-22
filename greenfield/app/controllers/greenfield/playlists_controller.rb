module Greenfield
  class PlaylistsController < Greenfield::ApplicationController
    include Listens

    before_filter :create_and_edit_unless_post_exists, :only => [:show, :edit]
    before_filter :require_login, :only => [:edit, :update]

    def show
      @post = find_post
      respond_to do |format|
        format.html do
          @page_title = "#{@post.user.display_name} - #{@post.title}"
        end

        format.mp3 do
          listen(@post.asset, register: false)
        end
      end
    end


    protected

    def create_and_edit_unless_post_exists
      if find_asset.user == current_user && !find_asset.greenfield_post
        post = find_asset.build_greenfield_post
        post.save!(:validate => false)
        redirect_to edit_user_post_path(post.user, post)
      end
    end

    def find_post
      find_asset.greenfield_post or raise ActiveRecord::RecordNotFound
    end

    def find_asset
      @alonetone_playlist = ::Playlist.find_by!(permalink: params[:playlist_id])
      @playlist ||= Greenfield::Playlist.new(@alonetone_playlist)
      if params[:position].present?
        @find_asset ||= Asset.where(id: @playlist.tracks.pluck(:asset_id), permalink: params[:position]).take!
      else
        @find_asset ||= @playlist.tracks.take!.asset
      end
      @playlist_position = @find_asset
    end

    def require_login
      if find_post.user != current_user
        flash[:message] = "You'll need to login to do that"
        super(find_post.user)
      end
    end
  end
end

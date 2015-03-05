module Greenfield
  class PostsController < Greenfield::ApplicationController
    include Listens

    before_filter :create_and_edit_unless_post_exists, :only => [:show, :edit]
    before_filter :authorize, :only => [:edit, :update]

    def show
      @post = find_post
      respond_to do |format|
        format.html do
          @page_title = "#{@post.user.display_name} - #{@post.title}"
        end

        format.mp3 do
          listen(@post.asset)
        end
      end
    end

    def edit
      @post = find_post
      @post.attached_assets.build
    end

    def update
      @post = find_post
      if @post.update_attributes(params[:post])
        redirect_to post_path(@post)
      else
        render :edit
      end
    end

    protected

    def create_and_edit_unless_post_exists
      if find_asset.user == current_user && !find_asset.greenfield_post
        post = find_asset.build_greenfield_post
        post.save!(:validate => false)
        redirect_to edit_post_path(post)
      end
    end

    def find_post
      find_asset.greenfield_post or raise ActiveRecord::RecordNotFound
    end

    def find_asset
      if params[:playlist_id]
        @playlist_position ||= (params[:position] ||= 1).to_i
        @playlist ||= Greenfield::Playlist.find_by(permalink: params[:playlist_id])
        @find_asset ||= @playlist.playlist_tracks.
                          where(:position => params[:position]).take!.alonetone_asset
      else
        id = params[:asset_permalink] || params[:id]
        @find_asset ||= Asset.find_by!(:permalink => id)
      end
    end

    def authorize
      if !current_user
        attempt_login_via_alonetone
      elsif find_post.user != current_user
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end

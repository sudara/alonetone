module Greenfield
  class PostsController < Greenfield::ApplicationController
    include Listens

    before_action :require_login, only: %i[edit update]

    def show
      @post = find_post
      respond_to do |format|
        format.html do
          @user = @post.user
          @page_title = "#{@post.title} — #{@user.display_name}"
        end

        format.mp3 do
          listen(@post.asset, register: false)
        end
      end
    end

    def edit
      if params[:playlist_id]
        @post = find_asset_from_playlist.greenfield_post
      else
        create_unless_post_exists
        @post = find_post
      end
      @user = @post.user
      @post.attached_assets.build
    end

    def update
      @post = find_post
      @playlist = params[:post].delete('playlist_id')
      if @post.update(post_params)
        if @playlist
          redirect_to user_playlist_post_path(@post.user, @playlist, @post)
        else
          redirect_to user_post_path(@post.user, @post)
        end
      else
        render :edit
      end
    end

    protected

    def post_params
      params.require(:post).permit(:body)
    end

    def create_unless_post_exists
      find_asset.build_greenfield_post.save!(validate: false) if find_asset.user == current_user && !find_asset.greenfield_post
    end

    def find_post
      find_asset.greenfield_post || raise(ActiveRecord::RecordNotFound)
    end

    def find_asset
      id = params[:asset_permalink] || params[:post_id] || params[:id] || params[:asset_id]
      @find_asset ||= Asset.find_by!(permalink: id)
    end

    def require_login
      if find_asset.user != current_user
        flash[:message] = "You'll need to login to do that"
        super(find_asset.user)
      end
    end
  end
end

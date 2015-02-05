module Greenfield
  class PostsController < Greenfield::ApplicationController
    before_filter :create_and_edit_unless_post_exists, :only => :show
    before_filter :authorize, :only => [:edit, :update]

    def show
      @post = find_post
      @page_title = "#{@post.user.display_name} - #{@post.title}"
    end

    def edit
      @post = find_post
      @post.attached_assets.build
    end

    def update
      @post = find_post
      if @post.update_attributes(params[:post])
        redirect_to user_post_path(@post.user, @post)
      else
        render :edit
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
      id = params[:asset_permalink] || params[:id]
      @find_asset ||= Asset.find_by!(:permalink => id)
    end

    def authorize
      if find_post.user != current_user
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end

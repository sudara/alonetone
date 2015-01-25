module Greenfield
  class PostsController < Greenfield::ApplicationController
    before_filter :render_new_unless_post_exists, :only => :show
    before_filter :redirect_to_edit_if_post_exists, :only => :new
    before_filter :extract_attached_asset_waveforms, :only => [:create, :update]

    def show
      @post = find_asset.greenfield_post
      @page_title = "#{@post.user.display_name} - #{@post.title}"
    end

    def new
      @post = find_asset.build_greenfield_post
      @post.attached_assets.build
    end

    def edit
      @post = find_asset.greenfield_post
    end

    def create
      @post = find_asset.build_greenfield_post(params[:post])

      if @post.save
        redirect_to user_post_path(@post.user, @post)
      else
        render :new
      end
    end

    def update
      @post = find_asset.greenfield_post
      if @post.update_attributes(params[:post])
        redirect_to user_post_path(@post.user, @post)
      else
        render :edit
      end
    end

    protected

    def render_new_unless_post_exists
      unless find_asset.greenfield_post
        new
        render 'new'
      end
    end

    def redirect_to_edit_if_post_exists
      if post = find_asset.greenfield_post
        redirect_to edit_user_post_path(post.user, post)
      end
    end

    def extract_attached_asset_waveforms
      params[:post][:attached_assets_attributes].each_with_index do |attrs, i|
        attrs[1][:waveform] = Greenfield::Waveform.extract(attrs[1][:mp3].path)
      end if params[:post][:attached_assets_attributes]
    end

    def find_asset
      id = params[:asset_permalink] || params[:id]
      @find_asset ||= current_user.assets.find_by!(:permalink => id)
    end
  end
end

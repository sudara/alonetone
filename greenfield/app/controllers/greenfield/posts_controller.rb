module Greenfield
  class PostsController < Greenfield::ApplicationController
    def new
      @post = asset_param.build_greenfield_post
      @post.attached_assets.build
    end

    def show
      @post = Greenfield::Post.find(params[:id])
      @page_title = "#{@post.asset.user.display_name} - #{@post.asset.title}"
    end

    def create
      @post = asset_param.build_greenfield_post(params[:post])

      params[:post][:attached_assets_attributes].each_with_index do |attrs, i|
        @post.attached_assets[i].extract_waveform(attrs[1][:mp3].path)
      end

      if @post.save
        redirect_to @post
      else
        render :new
      end
    end


    protected

    def asset_param
      id = params[:asset_id]
      id ||= params[:post].delete(:asset_id)
      current_user.assets.find(id)
    end
  end
end

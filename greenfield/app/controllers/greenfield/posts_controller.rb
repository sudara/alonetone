module Greenfield
  class PostsController < ApplicationController
    def show
      @post = Greenfield::Post.find(params[:id])
      @page_title = "#{@post.asset.user.display_name} - #{@post.asset.title}"
    end
  end
end

module Greenfield
  class PostsController < ApplicationController
    def show
      @asset = ::Asset.first
      @page_title = "#{@asset.user.display_name} - #{@asset.title}"
    end
  end
end

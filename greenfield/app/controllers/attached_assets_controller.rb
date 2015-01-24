module Greenfield
  class AttachedAssetsController < Greenfield::ApplicationController
    def show
      asset = Greenfield::Post.find(params[:post_id]).attached_assets.find(params[:id])
      redirect_to asset.mp3.expiring_url.gsub('s3.amazonaws.com/','')
    end
  end
end

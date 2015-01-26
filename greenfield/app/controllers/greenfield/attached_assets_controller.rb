module Greenfield
  class AttachedAssetsController < Greenfield::ApplicationController
    def show
      asset = find_post.attached_assets.find(params[:id])
      redirect_to asset.mp3.expiring_url.gsub('s3.amazonaws.com/','')
    end

    protected

    def find_post
      asset = current_user.assets.find_by!(:permalink => params[:post_id])
      Greenfield::Post.find_by!(:asset_id => asset.id)
    end
  end
end

module Greenfield
  class AttachedAssetsController < Greenfield::ApplicationController
    include ActionView::Helpers::NumberHelper

    before_filter :extract_waveform, :only => :create

    def show
      asset = find_post.attached_assets.find(params[:id])
      redirect_to asset.mp3.expiring_url.gsub('s3.amazonaws.com/','')
    end

    def create
      asset = find_post.attached_assets.build(params[:attached_asset])
      if asset.save
        render :json => { success: true, status: number_to_human_size(asset.mp3.size) }
      else
        render :json => { success: false, status: asset.errors.full_messages.join(' ') }
      end
    end

    protected

    def find_post
      asset = current_user.assets.find_by!(:permalink => params[:post_id])
      Greenfield::Post.find_by!(:asset_id => asset.id)
    end

    def extract_waveform
      param = params[:attached_asset]
      param[:waveform] = Greenfield::Waveform.extract(param[:mp3].path)
    end
  end
end

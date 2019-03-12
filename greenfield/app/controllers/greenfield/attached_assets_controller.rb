module Greenfield
  class AttachedAssetsController < Greenfield::ApplicationController
    include ActionView::Helpers::NumberHelper

    before_action :require_login, only: :create
    before_action :extract_waveform, only: :create

    def show
      asset = find_post.attached_assets.find(params[:id])
      redirect_to asset.mp3.expiring_url
    end

    def create
      asset = find_post.attached_assets.build(params[:attached_asset])
      if asset.save
        render json: { success: true, status: number_to_human_size(asset.mp3.size) }
      else
        render json: { success: false, status: asset.errors.full_messages.join(' ') }
      end
    end

    protected

    def find_post
      @asset ||= Asset.find_by!(permalink: params[:post_id])
      @post ||= Greenfield::Post.find_by!(asset_id: @asset.id)
    end

    def require_login
      if find_post.user != current_user
        flash[:message] = "You'll need to login to do that"
        super(find_post.user)
      end
    end

    def extract_waveform
      param = params[:attached_asset]
      param[:waveform] = Waveform.extract(param[:mp3].path)
    end
  end
end

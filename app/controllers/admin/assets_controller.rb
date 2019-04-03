module Admin
  class AssetsController < Admin::BaseController
    before_action :find_asset, only: %i[spam unspam]

    def index
      if permitted_params[:filter_by]
        @pagy, @assets = pagy(Asset.where(permitted_params[:filter_by]).recent)
      else
        @pagy, @assets = pagy(Asset.recent)
      end
    end

    def unspam
      @asset.ham!
      @asset.update_column :is_spam, false
      flash.notice = "Track was made public"
      redirect_back(fallback_location: root_path)
    end

    def spam
      @asset.spam!
      @asset.update_column :is_spam, true
      flash.notice = "Track was marked as spam"
      redirect_back(fallback_location: root_path)
    end

    def mark_group_as_spam
      scope = Asset.where(permitted_params[:mark_spam_by])
      assets = scope.not_spam

      assets.map(&:spam!)
      assets.update_all(is_spam: true)
      redirect_back(fallback_location: root_path)
    end

    private

    def find_asset
      @asset = Asset.find(params[:id])
    end

    def permitted_params
      params.permit(:filter_by, mark_spam_by: :user_id)
    end
  end
end

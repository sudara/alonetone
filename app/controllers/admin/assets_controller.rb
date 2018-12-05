module Admin
  class AssetsController < Admin::BaseController
    before_action :find_asset, only: %i[spam unspam]

    def index
      @pagy, @assets = pagy(Asset.recent)
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
      scope = Asset.where(params[:mark_spam_by].permit!)
      assets = scope.not_spam

      assets.map(&:spam!)
      assets.update_all(is_spam: true)
      redirect_back(fallback_location: root_path)
    end

    private

    def find_asset
      @asset = Asset.find(params[:id])
    end
  end
end

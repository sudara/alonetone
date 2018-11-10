module Admin
  class AssetsController < Admin::BaseController
    before_action :find_asset, only: %i[spam unspam]

    def index
      @pagy, @comments = pagy(Asset.all)
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
      binding.pry
      scope = Asset.where(params[:mark_spam_by].permit!)
      assets = scope.not_spam

      assets.map(&:spam!)
      assets.update_all(is_spam: true)
      redirect_back(fallback_location: root_path)
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end

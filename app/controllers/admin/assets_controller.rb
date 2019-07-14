module Admin
  class AssetsController < Admin::BaseController
    before_action :find_asset, only: %i[spam unspam delete]

    def index
      if permitted_params[:filter_by]
        @pagy, @assets = pagy(Asset.where(permitted_params[:filter_by]).recent)
      else
        @pagy, @assets = pagy(Asset.recent)
      end
    end

    def unspam
      @asset.ham!
      @asset.update_attribute :is_spam, false
    end

    def spam
      @asset.spam!
      @asset.update_attribute :is_spam, true
    end

    # not used at the moment
    def mark_group_as_spam
      scope = Asset.where(permitted_params[:mark_spam_by])
      assets = scope.not_spam

      assets.map(&:spam!)
      assets.update_all(is_spam: true)
    end

    def delete
      Assets::SoftDeleteRelations.new(asset: @asset).call
      @asset.soft_delete
    end

    private

    # find by id rather than permalink, since it's not unique
    def find_asset
      @asset = Asset.find(params[:id])
    end

    def permitted_params
      params.permit(:filter_by, mark_spam_by: :user_id)
    end
  end
end

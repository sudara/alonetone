module Admin
  class AssetsController < Admin::BaseController
    before_action :find_asset, only: %i[spam unspam delete restore]

    def index
      if permitted_params[:filter_by]
        # including with_deleted because all spam assets are also soft_deleted
        @pagy, @assets = pagy(Asset.with_deleted.where(permitted_params[:filter_by]).recent)
      else
        @pagy, @assets = pagy(Asset.recent)
      end
    end

    def unspam
      AssetCommand.new(@asset).restore_with_relations if @asset.soft_deleted?

      @asset.ham!
      @asset.update_attribute :is_spam, false
    end

    def spam
      @asset.spam!
      @asset.update_attribute :is_spam, true
      AssetCommand.new(@asset).soft_delete_with_relations
    end

    def delete
      AssetCommand.new(@asset).soft_delete_with_relations
    end

    def restore
      AssetCommand.new(@asset).restore_with_relations if @asset
    end

    private

    # find by id rather than permalink, since it's not unique
    # include with_deleted to be able to restore
    def find_asset
      @asset = Asset.with_deleted.find(params[:id])
    end

    def permitted_params
      params.permit(:filter_by, mark_spam_by: :user_id)
    end
  end
end

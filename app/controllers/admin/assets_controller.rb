module Admin
  class AssetsController < Admin::BaseController
    before_action :find_asset, only: %i[spam unspam delete restore]

    def index
      @pagy, @assets = pagy(Asset.filter_by(permitted_params[:filter_by]))
    end

    def unspam
      AssetCommand.new(@asset).restore_with_relations if @asset.soft_deleted?

      @asset.ham!
      @asset.update_attribute :is_spam, false
    end

    def spam
      AssetCommand.new(@asset).spam_and_soft_delete_with_relations
      redirect_to admin_assets_path(filter_by: :is_spam) unless params[:redirect] == "false"
    end

    def delete
      AssetCommand.new(@asset).soft_delete_with_relations
      redirect_to admin_assets_path(filter_by: :deleted)  unless params[:redirect] == "false"
    end

    def restore
      AssetCommand.new(@asset).restore_with_relations if @asset
      redirect_to admin_assets_path(filter_by: :not_spam) unless params[:redirect] == "false"
    end

    private

    # find by id rather than permalink, since it's not unique
    # include with_deleted to be able to restore
    def find_asset
      # binding.pry
      @asset = Asset.with_deleted.find(params[:id])
    end

    def permitted_params
      params.permit(:filter_by, :redirect, mark_spam_by: :user_id)
    end
  end
end

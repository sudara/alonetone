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
      respond_with_asset_row(fallback_filter: :not_spam)
    end

    def spam
      AssetCommand.new(@asset).spam_and_soft_delete_with_relations
      respond_with_asset_row(fallback_filter: :is_spam)
    end

    def delete
      AssetCommand.new(@asset).soft_delete_with_relations
      respond_with_asset_row(fallback_filter: :deleted)
    end

    def restore
      AssetCommand.new(@asset).restore_with_relations if @asset
      respond_with_asset_row(fallback_filter: :not_spam)
    end

    private

    def respond_with_asset_row(fallback_filter:)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@asset, partial: 'admin/assets/asset', locals: { asset: @asset })
        end
        format.html { redirect_to admin_assets_path(filter_by: fallback_filter) }
      end
    end

    # find by id rather than permalink, since it's not unique
    # include with_deleted to be able to restore
    def find_asset
      @asset = Asset.with_deleted.find(params[:id])
    end

    def permitted_params
      params.permit(:filter_by)
    end
  end
end

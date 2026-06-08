module Admin
  class AssetsController < Admin::BaseController
    layout 'admin'

    before_action :find_asset, only: %i[spam unspam delete restore purge]
    before_action :admin_only, only: %i[purge]

    def index
      @admin_title = 'Tracks'
      @pagy, @assets = pagy(Asset.filter_by(permitted_params[:filter_by]).includes(possibly_deleted_user: %i[profile avatar_image_blob]))
    end

    def most_played
      @admin_title = 'Most Played'
      @admin_range_enabled = true
      scope = admin_range ? Listen.where(created_at: admin_range) : Listen
      @play_counts = scope.group(:asset_id).order('count_all DESC').limit(25).count
      @assets_by_id = Asset.with_deleted.where(id: @play_counts.keys)
        .includes(possibly_deleted_user: %i[profile avatar_image_blob]).index_by(&:id)
    end

    def all_time
      @admin_title = 'All-Time Plays'
      @assets = Asset.order(listens_count: :desc).limit(25)
        .includes(possibly_deleted_user: %i[profile avatar_image_blob])
    end

    def unspam
      AssetCommand.new(@asset).unspam_and_restore_with_relations
      respond_with_asset_row(fallback_filter: :not_spam, notice: "\"#{@asset.title}\" has been unspammed and restored.")
    end

    def spam
      AssetCommand.new(@asset).spam_and_soft_delete_with_relations
      respond_with_asset_row(fallback_filter: :is_spam, notice: "\"#{@asset.title}\" has been marked as spam and hidden.")
    end

    def delete
      AssetCommand.new(@asset).soft_delete_with_relations
      respond_with_asset_row(fallback_filter: :deleted, notice: "\"#{@asset.title}\" has been deleted.")
    end

    def restore
      AssetCommand.new(@asset).restore_with_relations if @asset
      respond_with_asset_row(fallback_filter: :not_spam, notice: "\"#{@asset.title}\" has been restored.")
    end

    def purge
      if @asset.perma_deletable?
        title = @asset.title
        AssetCommand.new(@asset).destroy_with_relations
        flash[:ok] = "\"#{title}\" has been permanently deleted."
      else
        flash[:alert] = 'Only tracks soft-deleted more than 30 days ago can be permanently deleted.'
      end
      redirect_to admin_assets_path(filter_by: :deleted), status: :see_other
    end

    private

    def respond_with_asset_row(fallback_filter:, notice:)
      flash[:ok] = notice
      if turbo_stream_row_request?
        render turbo_stream: turbo_stream.replace(@asset, partial: 'admin/assets/asset', locals: { asset: @asset })
      elsif @asset.soft_deleted?
        redirect_to asset_soft_deleted_location(fallback_filter), status: :see_other
      else
        redirect_back(fallback_location: admin_assets_path(filter_by: fallback_filter), status: :see_other)
      end
    end

    # find by id rather than permalink, since it's not unique
    # include with_deleted to be able to restore
    def find_asset
      @asset = Asset.with_deleted.find(params[:id])
    end

    def asset_soft_deleted_location(fallback_filter)
      return admin_assets_path(filter_by: fallback_filter) if admin_row_request?
      return admin_assets_path(filter_by: fallback_filter) if request.referer.blank?
      return admin_assets_path(filter_by: fallback_filter) if @asset.possibly_deleted_user.soft_deleted?

      user_home_path(@asset.possibly_deleted_user)
    end

    def permitted_params
      params.permit(:filter_by)
    end
  end
end

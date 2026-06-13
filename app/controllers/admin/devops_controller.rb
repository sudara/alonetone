module Admin
  class DevopsController < Admin::BaseController
    before_action :admin_only, only: %i[purge]

    LISTED_DESTROYABLE = 50

    def index
      @admin_title = 'Devops'
      @destroyable_users_count = User.destroyable.count
      @destroyable_assets_count = Asset.destroyable.count
      @destroyable_comments_count = Comment.purgeable_spam_or_deleted.count
      @destroyable_users = User.destroyable.order(deleted_at: :asc).limit(LISTED_DESTROYABLE)
      @destroyable_assets = Asset.destroyable.order(deleted_at: :asc).limit(LISTED_DESTROYABLE)
        .includes(:possibly_deleted_user)
      @destroyable_comments = Comment.purgeable_spam_or_deleted
        .order(Arel.sql('COALESCE(comments.deleted_at, comments.updated_at) ASC')).limit(LISTED_DESTROYABLE)
    end

    def purge
      PurgeEligibleRecordsJob.perform_later
      flash[:ok] = 'Queued a purge of all records soft-deleted more than 30 days ago.'
      redirect_to admin_devops_path, status: :see_other
    end
  end
end

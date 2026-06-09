module Admin
  class DevopsController < BaseController
    before_action :admin_only, only: %i[purge]

    def index
      @admin_title = 'Devops'
      @destroyable_users = User.destroyable.count
      @destroyable_assets = Asset.destroyable.count
    end

    def purge
      PurgeEligibleRecordsJob.perform_later
      flash[:ok] = 'Queued a purge of all records soft-deleted more than 30 days ago.'
      redirect_to admin_devops_path, status: :see_other
    end
  end
end

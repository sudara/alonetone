class PurgeEligibleRecordsJob < ApplicationJob
  queue_as :default

  # Permanently destroys everything soft-deleted more than 30 days ago.
  # Normally run by system cron; the Devops panel triggers it on demand.
  def perform
    User.destroy_deleted_accounts_older_than_30_days
    Asset.destroy_deleted_accounts_older_than_30_days
  end
end

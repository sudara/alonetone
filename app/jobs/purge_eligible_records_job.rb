class PurgeEligibleRecordsJob < ApplicationJob
  queue_as :default

  # Permanently destroys records soft-deleted more than 30 days ago.
  # Normally run by system cron; the Devops panel triggers it on demand.
  def perform(users: true, assets: true, limit: nil, dry_run: false)
    Rails.logger.info(
      "PurgeEligibleRecordsJob starting users=#{users} assets=#{assets} limit=#{limit.inspect} dry_run=#{dry_run}"
    )

    purged_users = users ? User.destroy_deleted_accounts_older_than_30_days(limit: limit, dry_run: dry_run) : 0
    purged_assets = assets ? Asset.destroy_deleted_accounts_older_than_30_days(limit: limit, dry_run: dry_run) : 0

    Rails.logger.info(
      "PurgeEligibleRecordsJob finished users=#{purged_users} assets=#{purged_assets} dry_run=#{dry_run}"
    )
  end
end

class PurgeEligibleRecordsJob < ApplicationJob
  queue_as :default

  # Permanently destroys records eligible for the 30-day admin purge.
  # Normally run by system cron; the Devops panel triggers it on demand.
  def perform(users: true, assets: true, comments: true, limit: nil, dry_run: false)
    Rails.logger.info(
      "PurgeEligibleRecordsJob starting users=#{users} assets=#{assets} comments=#{comments} limit=#{limit.inspect} dry_run=#{dry_run}"
    )

    purged_users = users ? User.destroy_deleted_accounts_older_than_30_days(limit: limit, dry_run: dry_run) : 0
    purged_assets = assets ? Asset.destroy_deleted_accounts_older_than_30_days(limit: limit, dry_run: dry_run) : 0
    purged_comments = comments ? Comment.destroy_spam_or_deleted_older_than_30_days(limit: limit, dry_run: dry_run) : 0

    Rails.logger.info(
      "PurgeEligibleRecordsJob finished users=#{purged_users} assets=#{purged_assets} comments=#{purged_comments} dry_run=#{dry_run}"
    )
  end
end

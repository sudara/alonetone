class PurgeListensByIpJob < ApplicationJob
  queue_as :default

  # Deletes every listen from an IP in batches (the listens table is 15 years old),
  # then recomputes the counter caches on the assets and track owners it touched.
  def perform(ip)
    return if ip.blank?

    scope = Listen.with_deleted.where(ip: ip)
    asset_ids = scope.distinct.pluck(:asset_id).compact
    owner_ids = scope.distinct.pluck(:track_owner_id).compact

    scope.in_batches(of: 5000).delete_all

    asset_ids.each { |id| Asset.reset_counters(id, :listens) }
    owner_ids.each { |id| User.reset_counters(id, :track_plays) }
  end
end

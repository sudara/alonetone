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

    # reset_counters with an id slice runs one grouped COUNT per slice, not one per record
    asset_ids.each_slice(5000) { |slice| Asset.reset_counters(slice, :listens) }
    owner_ids.each_slice(5000) { |slice| User.reset_counters(slice, :track_plays) }
  end
end

class PurgeListensByIpJob < ApplicationJob
  queue_as :default

  # Deletes every listen from an IP in batches (the listens table is 15 years old).
  # Each batch's delete and counter decrements share a transaction so a mid-run crash retries cleanly.
  BATCH_SIZE = 5000

  def perform(ip)
    return if ip.blank?

    Listen.with_deleted.where(ip: ip).in_batches(of: BATCH_SIZE) do |batch|
      Listen.transaction do
        asset_counts = batch.group(:asset_id).count
        owner_counts = batch.group(:track_owner_id).count
        batch.delete_all
        decrement(Asset, asset_counts)
        decrement(User, owner_counts)
      end
    end
  end

  private

  # Decrement rather than reset: soft-deletes never adjust these counters, so they mean "created minus purged".
  def decrement(model, counts)
    counts.except(nil).group_by(&:last).each do |count, pairs|
      model.update_counters(pairs.map(&:first), listens_count: -count)
    end
  end
end

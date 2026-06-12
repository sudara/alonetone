class PurgeListensByIpJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 5000

  def perform(ip)
    return if ip.blank?

    if ip.include?('/')
      purge_range(ip)
    else
      purge_ip(ip)
    end
  end

  private

  def purge_range(cidr)
    range = IPAddr.new(cidr)
    return unless range.ipv4?

    covered_ips(range).each { |ip| purge_ip(ip) }
  end

  # Narrows with a LIKE over the octets the mask fully covers (index range scan), then filters exactly.
  def covered_ips(range)
    prefix = range.to_s.split('.').first(range.prefix / 8).join('.')
    scope = Listen.with_deleted
    scope = scope.where('ip LIKE ?', "#{prefix}.%") if prefix.present?
    scope.distinct.pluck(:ip).select { |ip| covered?(range, ip) }
  end

  def covered?(range, ip)
    range.include?(ip)
  rescue IPAddr::InvalidAddressError
    false
  end

  # Deletes every listen from an IP in batches (the listens table is 15 years old).
  # Each batch's delete and counter decrements share a transaction so a mid-run crash retries cleanly.
  def purge_ip(ip)
    Listen.with_deleted.where(ip: ip).in_batches(of: BATCH_SIZE) do |batch|
      Listen.transaction do
        asset_counts = batch.group(:asset_id).count
        owner_counts = batch.group(:track_owner_id).count
        batch.delete_all
        Listen.decrement_counter_caches(asset_counts: asset_counts, owner_counts: owner_counts)
      end
    end
  end
end

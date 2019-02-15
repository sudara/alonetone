class AssetNotificationJob < ActiveJob::Base
  queue_as :mailers

  def perform(asset_ids:, follower_id:)
    assets = Asset.where(id: asset_ids)
    follower = User.find_by(id: follower_id)

    return unless follower&.email
    return AssetNotification.upload_notification(assets.first, follower.email).deliver_now if assets.count == 1
    AssetNotification.upload_mass_notification(assets, follower.email).deliver_now
  end
end

class AssetNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(asset_ids:, user_id:)
    assets = Asset.where(id: asset_ids).to_a
    follower = User.find_by(id: user_id)

    return unless follower&.email && assets.present?
    return AssetNotification.upload_notification(assets.first, follower.email).deliver_now if assets.count == 1
    AssetNotification.upload_mass_notification(assets, follower.email).deliver_now
  end
end

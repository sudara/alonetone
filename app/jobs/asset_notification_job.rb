class AssetNotificationJob < ActiveJob::Base
  queue_as :mailers

  def perform(asset_ids:, user_id: )
    assets = Asset.where(id: asset_ids)
    user = User.find_by(id: user_id)

    return unless user&.email
    return AssetNotification.upload_notification(assets.first, user).deliver_now if assets.count == 1
    AssetNotification.upload_mass_notification(assets, user).deliver_now
  end
end

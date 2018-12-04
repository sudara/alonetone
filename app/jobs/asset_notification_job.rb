class AssetNotificationJob < ActiveJob::Base
  queue_as :mailers

  def perform(asset_ids: asset_ids, user_id: user_id)
    assets = Asset.find_by(id: asset_ids)
    user = User.find_by(id: user_id)
    AssetNotification.upload_notification(assets, user).deliver_now if assets && user&.email
  end
end

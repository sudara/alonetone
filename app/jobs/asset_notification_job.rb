class AssetNotificationJob < ActiveJob::Base
  queue_as :mailers

  def perform(asset_id, follower_id)
    asset = Asset.find_by(id: asset_id)
    email = User.find_by(id: follower_id).try(:email)
    if asset && email
      AssetNotification.upload_notification(asset, email).deliver_now
    end
  end
end

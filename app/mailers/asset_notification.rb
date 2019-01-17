class AssetNotification < ApplicationMailer
  def upload_notification(asset, email, _sent_at = Time.now)
    @track = asset.name
    @description = asset.description
    @name = asset.user.name
    @user = asset.user
    @title = asset.title.present? ? asset.title : "new track"
    @play_link = play_link_for(asset)
    @user_link = user_link_for(asset)
    @stop_following_link = stop_following_link
    @unsubscribe_link = unsubscribe_link
    @exclamation = %w[Sweet Yes Oooooh Alright Booya Yum Celebrate OMG].sample
    mail subject: "[alonetone] '#{asset.user.name}' uploaded a new track!", to: email
  end

  protected

  def user_link_for(asset)
    'https://' + hostname + '/' + asset.user.login
  end

  def play_link_for(asset)
    user_link_for(asset) + '/tracks/' + asset.id.to_s
  end

  def stop_following_link
    'https://' + hostname + '/unfollow/' + @user.login
  end

  def unsubscribe_link
    'https://' + hostname + '/notifications/unsubscribe'
  end
end

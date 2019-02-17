class AssetNotification < ApplicationMailer
  def upload_notification(asset, follower_email, _sent_at = Time.now)
    @artist = asset.user
    @track = asset
    @play_link = play_link_for(asset)
    @stop_following_link = stop_following_link
    @unsubscribe_link = unsubscribe_link
    @exclamation = %w[Sweet Yes Oooooh Alright Booya Yum Celebrate OMG].sample
    mail subject: "[alonetone] '#{@artist.name}' uploaded a new track!", to: follower_email
  end

  def upload_mass_notification(assets, follower_email, _sent_at = Time.now)
    @artist = assets.first.user
    @assets = generate_asset_hash(assets)
    @stop_following_link = stop_following_link
    @unsubscribe_link = unsubscribe_link
    @exclamation = %w[Sweet Yes Oooooh Alright Booya Yum Celebrate OMG].sample
    @upload_user_url = user_link_for(assets.first)
    mail subject: "[alonetone] '#{@artist.name}' uploaded a new track!", to: follower_email
  end

  protected

  # I'm sure there is some fancy shmancy way to do the same thing
  # but I can't think of it right now.
  def generate_asset_hash(assets)
    assets_array = []
    assets.each do |asset|
      assets_array << { title: asset.title, play_link: play_link_for(asset) } if asset.title
    end
    assets_array
  end

  def user_link_for(asset)
    'https://' + hostname + '/' + asset.user.login
  end

  def play_link_for(asset)
    user_link_for(asset) + '/tracks/' + asset.id.to_s
  end

  def stop_following_link
    'https://' + hostname + '/unfollow/' + @artist.login
  end

  def unsubscribe_link
    'https://' + hostname + '/notifications/unsubscribe'
  end
end

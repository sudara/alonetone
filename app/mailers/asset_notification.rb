class AssetNotification < ActionMailer::Base
  default from: Alonetone.email

  def upload_notification(assets, user, _sent_at = Time.now)
    @user = user
    @tracks = generate_track_hash(assets)
    @stop_following_link = stop_following_link
    @unsubscribe_link = unsubscribe_link
    @exclamation = %w[Sweet Yes Oooooh Alright Booya Yum Celebrate OMG].sample
    @upload_user_url = user_link_for(assets.first)
    mail subject: "[alonetone] '#{@user.name}' uploaded a new track!", to: user.email
  end

  protected

  # I'm sure there is some fancy shmancy way to do the same thing
  # but I can't think of it right now.
  def generate_track_hash(assets)
    assets_array = []
    assets.each do |asset|
      assets_array << { title: asset.title, play_link: play_link_for(asset) } if asset.title
    end
    assets_array
  end

  def user_link_for(asset)
    'https://' + Alonetone.url + '/' + asset.user.login
  end

  def play_link_for(asset)
    user_link_for(asset) + '/tracks/' + asset.id.to_s
  end

  def stop_following_link
    'https://' + Alonetone.url + '/unfollow/' + @user.login
  end

  def unsubscribe_link
    'https://' + Alonetone.url + '/notifications/unsubscribe'
  end
end

class AlbumNotification < ActionMailer::Base
  default from: Alonetone.email

  def album_release(playlist, email, _sent_at = Time.now)
    @title = playlist.title
    @name = playlist.user.name
    @user = playlist.user
    @num_tracks = playlist.tracks_count
    @play_link = play_link_for(asset)
    @user_link = user_link_for(asset)
    @exclamation = %w[Sweet Yes Oooooh Alright Booya Yum Celebrate OMG].sample
    mail subject: "[alonetone] '#{asset.user.name}' uploaded a new album!", to: email
  end

  protected

  def user_link_for(asset)
    'https://' + Alonetone.url + '/' + asset.user.login
  end

  def play_link_for(asset)
    user_link_for(asset) + '/playlists/' + playlist.id.to_s
  end

  def download_link_for(asset)
    play_link_for(asset) + '.mp3?source=email'
  end
end

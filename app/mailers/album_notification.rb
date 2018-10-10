class AlbumNotification < ActionMailer::Base
  default from: Alonetone.email

  def album_release(playlist, email, _sent_at = Time.now)
    @title = playlist.title
    @name = playlist.user.name
    @user = playlist.user
    @num_tracks = playlist.tracks_count
    @play_link = play_link_for(playlist)
    @user_link = user_link
    @stop_following_link = stop_following_link
    @unsubscribe_link = unsubscribe_link
    @exclamation = %w[Sweet Yes Oooooh Alright Booya Yum Celebrate OMG].sample
    mail subject: "[alonetone] '#{playlist.user.name}' released a new album!", to: email
  end

  protected

  def user_link
    'https://' + Alonetone.url + '/' + @user.login
  end

  def play_link_for(playlist)
    user_link + '/playlists/' + playlist.to_param
  end

  def stop_following_link
    'https://' + Alonetone.url + '/unfollow/' + @user.login
  end

  def unsubscribe_link
    'https://' + Alonetone.url + '/notifications/unsubscribe'
  end
end

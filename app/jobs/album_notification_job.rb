class AlbumNotificationJob < ActiveJob::Base
  queue_as :mailers

  def perform(playlist_id, follower_id)
    playlist = Playlist.find_by(id: playlist_id)
    email = User.find_by(id: follower_id).try(:email)
    AlbumNotification.album_release(playlist, email).deliver_now if playlist && email
  end
end

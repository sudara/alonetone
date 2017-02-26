module PlaylistsHelper
  
  def title_and_year_for(playlist)
    title = "#{playlist.title}"
    title += " (#{playlist.year})" if playlist.year
    title
  end

  def allow_greenfield_playlist_downloads?(user)
    user.greenfield_enabled? && Alonetone.storage.s3?
  end

  def greenfield_upload_form(user, playlist, &block)
    data = {
      'expected-content-type' => Greenfield::PlaylistDownload::CONTENT_TYPE.join(' '),
      'max-file-size' => Greenfield::PlaylistDownload::MAX_SIZE,
      'max-file-size-human' =>
        number_to_human_size(Greenfield::PlaylistDownload::MAX_SIZE).downcase
    }
    options = {
      id: "s3-uploader",
      key_starts_with: "greenfield/",
      acl: "authenticated-read",
      callback_url: downloads_user_playlist_path(user, playlist),
      max_file_size: Greenfield::PlaylistDownload::MAX_SIZE,
      data: data
    }
    s3_uploader_form(options){ yield("") }
  end
end

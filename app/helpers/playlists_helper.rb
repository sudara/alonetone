module PlaylistsHelper

  def title_and_year_for(playlist)
    title = "#{playlist.title}"
    title += " (#{playlist.year})" if playlist.year.present?
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

  def external_link_for(link)
    text = case link
    when /spotify/i
      '<i class="fa fa-spotify"></i>Spotify<span class="action-text">Stream</span>'
    when /app\=music/i
      '<i class="fa fa-apple"></i>Apple Music<span class="action-text">Stream</span>'
    when /app\=itunes/i
      '<i class="fa fa-apple"></i>iTunes<span class="action-text">Buy</span>'
    when /play\.google/i
      '<i class="fa fa-google"></i>Google<span class="action-text">Stream</span>'
    else
      '<i class="fa fa-link"></i>Website<span class="action-text">Visit</span>'
    end.html_safe
    link_to(text, link).html_safe
  end
end

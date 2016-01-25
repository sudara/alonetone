module PlaylistsHelper
  
  def title_and_year_for(playlist)
    title = "#{playlist.title}"
    title += " (#{playlist.year})" if playlist.year
    title
  end

  def greenfield_upload_form(user, playlist, &block)
    s3_uploader_form(id: "s3-uploader",
                     key_starts_with: "greenfield/",
                     acl: "authenticated-read",
                     callback_url: downloads_user_playlist_path(user, playlist),
                     max_file_size: 2000.megabytes) do
      yield("")
    end
  end
end

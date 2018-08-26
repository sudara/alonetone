module GreenfieldPlaylistDownloads
  def create_greenfield_download
    @unique_id = params[:unique_id]
    @greenfield_download = @playlist.greenfield_downloads.create(
      s3_path: URI.unescape(params[:filepath]),
      attachment_file_name: params[:filename],
      attachment_file_size: params[:filesize].to_i,
      attachment_content_type: params[:filetype],
      attachment_updated_at: params[:lastModifiedDate],
      title: params[:filename]
    )
  end
end

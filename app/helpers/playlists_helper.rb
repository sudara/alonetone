module PlaylistsHelper
  
  def title_and_year_for(playlist)
    title = "#{playlist.title}"
    title += " (#{playlist.year})" if playlist.year
    title
  end
end

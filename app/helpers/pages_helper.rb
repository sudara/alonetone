module PagesHelper
    
  # proper date format for google sitemaps
  def w3c_date(date)
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end
  
  def sitemap(loc,lastmod,changefreq,priority)
    "<url>
      <loc>" + loc + "</loc>
      <lastmod>" + w3c_date(lastmod) + "</lastmod>
      <changefreq>" + changefreq + "</changefreq>
      <priority>" + priority + "</priority>
    </url>
    "
  end
  
  def twenty_four(permalink, type)
    album = type == :playlist ? grab_playlist(permalink) : grab_track(permalink)
    result = '<div class="album">'
    result += link_to image_tag(album[:image]), album[:link], :class => 'pic'
    result += link_to truncate(album[:title],38), album[:link], :class => 'album_title'
    result += link_to album[:username], album[:link], :class => 'artist_name'
    result += '</div>'
    result
  rescue
     ''
  end
  
  def grab_playlist(permalink)
    playlist = Playlist.find_by_permalink(permalink)
    { :image => playlist.cover(:small),
      :link  => user_playlist_path(playlist.user, playlist.permalink),
      :username => playlist.user.name,
      :title   =>  playlist.title}
  end
  
  def grab_track(permalink)
    track = Asset.find_by_permalink(permalink)
    { :image => track.user.avatar(:small),
      :link  => user_track_path(track.user, track.permalink),
      :username => track.user.name,
      :title =>    track.name}    
  end
  
end

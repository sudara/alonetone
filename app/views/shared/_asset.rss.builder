xml.item do
  url = user_track_url(asset.user, asset, :format => :mp3, :referer => 'itunes')
  xml.title  asset.name 
  xml.link  user_track_url(asset.user, asset)
  xml.guid url
  xml.pubDate  rss_date asset.created_at
  xml.enclosure :url=> url, :type=>'audio/mpeg', :size => asset.mp3_file_size
  xml.itunes :summary, asset.description
  xml.itunes :duration, asset.length
  xml.itunes :author, asset.user.name
  xml.itunes :keywords, "#{asset.name} #{asset.user.name} alonetone"
end

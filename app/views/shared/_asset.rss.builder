  xml.item do
    url = formatted_user_track_url(asset.user, asset, :mp3, :referer => 'itunes')
    xml.title  asset.name 
    xml.link  user_track_url(asset.user, asset)
    xml.guid url
    xml.pubDate  rss_date asset.created_at
    xml.enclosure :url=> url,:type=>'audio/mpeg', :size => asset.size
    xml.itunes :summary, asset.description
    xml.description, asset.description
    xml.itunes :duration, asset.length
    xml.itunes :author, asset.user.name
    xml.itunes :keywords, "#{asset.name} #{asset.user.name} alonetone"
  end

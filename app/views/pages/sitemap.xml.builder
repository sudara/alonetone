xml.instruct!
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc         "http://alonetone.com"
    xml.lastmod     w3c_date(Time.now)
    xml.changefreq  "daily"
    xml.priority  0.9
  end
  ['signup', 'about', 'users', 'updates','user_reports'].each do |static|
    xml.url do
      xml.loc "http://alonetone.com/#{static}"
      xml.lastmod w3c_date(User.find(:all, :order => 'created_at DESC').first.created_at)
      xml.changefreq "daily"
      xml.priority 0.8
    end
  end
  @users.each do |user|
    xml.url do
      xml.loc         user_home_url(user)
      xml.lastmod     w3c_date(user.last_seen_at || user.updated_at)
      xml.changefreq  "weekly"
      xml.priority 0.7
    end if user.activated?
    xml.url do
      xml.loc user_tracks_url(user)
      xml.lastmod w3c_date(user.assets.first.created_at)
      xml.changefreq  "weekly"
      xml.priority 0.6
    end if user.assets_count > 0 
    xml.url do
      xml.loc user_playlists_url(user)
      xml.lastmod w3c_date(user.playlists.first.updated_at)
      xml.changefreq "weekly"
      xml.priority 0.6
    end if user.playlists_count > 0
    
    if user.assets.size > 0 
      user.assets.each do |asset|
        xml.url do
          xml.loc user_track_url(user, asset)
          xml.lastmod w3c_date(asset.created_at)
          xml.changefreq 'weekly'
          xml.priority 0.5
        end
      end
    end
    
  end
end
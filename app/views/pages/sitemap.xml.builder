xml.instruct!
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc         "http://alonetone.com"
    xml.lastmod     w3c_date(Time.now)
    xml.changefreq  "daily"
    xml.priority  0.9
  end
  ['login', 'signup', 'about', 'search'].each do |static|
    xml.url do
      xml.loc "http://alonetone.com/#{static}"
      xml.lastmod w3c_date(Time.now)
      xml.changefreq "monthly"
      xml.priority 0.8
    end
  end
  ['users', 'updates','feedback','stats', 'radio/latest', 'radio/favorites', 'radio/popular', 'radio/mangoz_shuffle','radio/most_favorited','features', 'forums'].each do |static|
    xml.url do
      xml.loc "http://alonetone.com/#{static}"
      xml.lastmod w3c_date(Time.now)
      xml.changefreq "daily"
      xml.priority 0.7
    end
  end
  
  Forum.ordered.each do |forum|
    xml.url do
      xml.loc forum_url(forum.permalink)
      xml.lastmod w3c_date(forum.posts.last.created_at)
      xml.changefreq  "daily"
      xml.priority 0.6
    end
  end
  @users.each do |user|
    xml.url do
      xml.loc         user_home_url(user)
      xml.lastmod     w3c_date(user.last_seen_at || user.updated_at)
      xml.changefreq  "daily"
      xml.priority (user.has_tracks? ? 0.8 : 0.3)
    end if user.activated?
    xml.url do
      xml.loc user_tracks_url(user)
      xml.lastmod w3c_date(user.assets.first.created_at)
      xml.changefreq  "daily"
      xml.priority 0.5
    end if user.assets_count > 0 
    xml.url do
      xml.loc user_playlists_url(user)
      xml.lastmod w3c_date(user.playlists.first.updated_at)
      xml.changefreq "weekly"
      xml.priority 0.5
    end if user.playlists_count > 0
    xml.url do
      xml.loc comments_url(:login => user.login)
      xml.lastmod w3c_date(user.comments.public.first.updated_at)
      xml.changefreq "daily"
      xml.priority 0.5
    end if user.comments.public.size > 0
    
    
    if user.assets_count > 0 
      user.assets.each do |asset|
        xml.url do
          xml.loc user_track_url(user, asset.permalink)
          xml.lastmod w3c_date(asset.created_at)
          xml.changefreq 'weekly'
          xml.priority 0.5
        end
      end
    end
    
  end
end
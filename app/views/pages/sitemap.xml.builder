xml.instruct!
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc         "http://alonetone.com"
    xml.lastmod     w3c_date(Time.now)
    xml.changefreq  "daily"
    xml.priority  0.9
  end
  ['login', 'signup', 'about','24houralbum','rpmchallenge'].each do |static|
    xml.url do
      xml.loc "http://alonetone.com/#{static}"
      xml.lastmod w3c_date(Time.now)
      xml.changefreq "monthly"
      xml.priority 0.8
    end
  end
  ['users','stats', 'radio', 'radio/latest', 'radio/favorites', 'radio/popular', 'radio/mangoz_shuffle','radio/most_favorited','forums', 'forums/posts'].each do |static|
    xml.url do
      xml.loc "http://alonetone.com/#{static}"
      xml.lastmod w3c_date(Time.now)
      xml.changefreq "daily"
      xml.priority 0.7
    end
  end
  
  Forum.ordered.find_each do |forum|
    xml.url do
      xml.loc forum_url(forum.permalink)
      xml.lastmod w3c_date(forum.posts.find(:last).created_at)
      xml.changefreq  "daily"
      xml.priority 0.6
    end
  end
  
  User.activated.find_each(:batch_size => 1000) do |user|
    # user home
    xml.url do
      xml.loc         user_home_url(user)
      xml.lastmod     w3c_date(user.last_seen_at || user.updated_at)
      xml.changefreq  "daily";
      xml.priority(user.has_tracks? ? 0.8 : 0.1)
    end 
    
    xml.url do
      xml.loc user_tracks_url(user)
      xml.lastmod w3c_date(Time.now)
      xml.changefreq  "daily"
      xml.priority 0.6
    end if user.has_tracks?
    
    
    # user comments
    xml.url do
      xml.loc user_comments_url(user)
      xml.lastmod w3c_date(Time.now)
      xml.changefreq "daily"
      xml.priority(user.has_tracks? ? 0.4 : 0.1)
    end 
    
  end
  
  Asset.find_each(:include => :user) do |asset|
    xml.url do
      xml.loc         user_track_url(asset.user.login, asset.permalink)
      xml.lastmod     w3c_date(asset.created_at)
      xml.changefreq  'weekly'
      xml.priority    0.5
    end  
  end
  
  Playlist.find_each(:include => :user) do |playlist|
     xml.url do
       xml.loc user_playlists_url(playlist.user)
       xml.lastmod w3c_date(playlist.updated_at)
       xml.changefreq "weekly"
       xml.priority 0.5
     end 
  end
    
end
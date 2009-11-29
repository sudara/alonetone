ActionController::Routing::Routes.draw do |map|
  map.resources :groups

  map.admin 'secretz', :controller => 'secretz'
  
  # manual, ghetto, overriding links
  map.rpm_challenge 'rpmchallenge', :controller => 'pages', :action => 'rpm_challenge'
  map.twentyfour '24houralbum', :controller => 'pages', :action => 'twentyfour'  
  
  
  map.feedback 'feedback', :controller => 'user_reports'
  map.resources :features, :sessions, :user_reports
  map.blog_home 'blog', :controller => 'updates', :action => 'index'
  map.resources :blog, :controller => 'updates'
  map.resources :updates
  map.resources :comments, :member => {:unspam => :get}
    

  map.sitemap 'sitemap.xml', :controller => 'pages', :action => 'sitemap', :format => 'xml'
  map.about 'about/:action', :controller => 'pages'
  map.halp  'about/halp/:action', :controller => 'pages'
  
  
  map.signup   'signup',        :controller => 'users',   :action => 'new'
  map.settings 'settings',      :controller => 'users',   :action => 'edit'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.login    'login',         :controller => 'sessions', :action => 'create'
  map.logout   'logout',        :controller => 'sessions', :action => 'destroy'

  # shortcut to profile
  map.profile ':login/bio', :controller => 'users', :action => 'bio'
  
  map.connect '/latest.:format', :controller => 'assets', :action => 'latest'
  
  # latest mp3s uploaded site-wide
  map.latest '/latest/:latest', :controller => 'assets', :action => 'latest'
  
  map.radio_home 'radio', :controller => 'assets', :action => 'radio'
  map.radio 'radio/:source/:per_page/:page', :controller => 'assets', :action => 'radio', :defaults =>{:per_page => 5, :page => 1}
  
  # top 40
  map.top '/top/:top', :controller => 'assets', :action => 'top'

  map.users_default '/users/by/activity/:page', :controller => 'users', :action => 'index', :sort => 'active', :defaults => {:page => 1}
  map.sorted_users '/users/by/:sort/:page', :controller => 'users', :action => 'index', :defaults => {:page => 1}
  
  map.listens  ':login/history', :controller => 'listens'
  
  map.all_comments 'comments', :controller => 'comments'
  map.user_comments ':login/comments', :controller => 'comments'
  map.user_stats ':login/stats.:format', :controller => 'users', :action => 'stats'
  
  map.hot_track 'hot_track/:position.:format', 
    :controller => 'assets', 
    :action     => 'hot_track', 
    :format     => 'mp3'
    
  map.user_plus ':login/plus', :controller => 'source_files', :action => 'index'

  map.resources :forums, :has_many => :posts do |forum|
    forum.resources :topics do |topic|
      topic.resources :posts
    end
    forum.resources :posts
  end
  
  map.resources :posts, :collection => {:search => :get}


  map.resources :users, :controller => :users, 
    :member => {:attach_pic => :post, :sudo => :any,
    :toggle_favorite => :any, :toggle_follow => :any} do |user|
    user.resources :source_files, :path_prefix => ':login'
    # TODO: Confusing, because Tracks is also a model. Don't confuse this route, this is indeed for the Assets model
    user.resources :tracks, :controller => :assets, :member => {:share => :get, :destroy => :any, :stats => :get}, :collection => {:latest => :get, :search => :post, :mass_edit => :get}, :path_prefix => ':login', :member_path => ':login/tracks/:id' do |track|
      track.resources :comments
    end
    user.favorites 'favorites', :controller => 'playlists', :action => 'favorites',:path_prefix => ':login'
    user.posts 'posts', :controller => 'posts', :action => 'index', :path_prefix => ':login'
    
    # TODO - figure out a way to use :member_path with rails 2
    # http://dev.rubyonrails.org/changeset/8227
    # for now, i have to specify port to allow :permalink and :id to be sent at the same time
    user.resources :playlists, :collection => {:latest => :get, :sort => :any}, 
    :member=> {:set_playlist_title => :post, :set_playlist_description => :post, 
              :attach_pic => :post, :remove_track => :any, :sort_tracks => :post, 
              :add_track => :post, :destroy => :any},
    :path_prefix => ':login' do |playlist|
    playlist.resources :comments
   end
  end
  
  map.search 'search', :controller => 'search', :action => 'index'
  map.search_query 'search/:query', :controller => 'search', :action => 'index'
  map.namespace(:admin) do |admin|
    admin.resources :layouts
    admin.resources :users
  end
  
  
  map.root :controller => 'assets', :action => 'latest'
  
  map.user_home ':login', :controller => 'users', :action => 'show'
  map.user_feeds ':login.:format', :controller => 'users', :action => 'show'
  
end

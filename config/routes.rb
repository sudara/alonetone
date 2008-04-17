ActionController::Routing::Routes.draw do |map|
 
  map.resource  :sessions
  map.resources :comments
  map.resources :user_reports
  
  # RESTFUL WORKAROUND FOR FACEBOOK
  map.facebook_home '', :controller => 'facebook_accounts', :conditions => {:canvas => true}
  map.resources 'facebook', :controller => 'facebook_accounts', :member => {:add_to_profile => :post, :remove_from_profile => :get}, :conditions =>{:canvas => true}
  #map.facebook_resources :facebook_accounts, 'facebook_accounts', :controller => 'facebook_accounts', :condition => {:canvas => true}

  map.sitemap 'sitemap.xml', :controller => 'pages', :action => 'sitemap', :format => 'xml'
  map.about 'about/:action', :controller => 'pages'
  map.halp  'about/halp/:action', :controller => 'pages'
  
  map.search 'search', :controller => 'search', :action => 'index'
  
  map.resources :updates

  map.logged_exceptions 'logged_exceptions/:action/:id',    :controller => 'logged_exceptions'
   
  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  
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
  
  # top 40
  map.top '/top/:top', :controller => 'assets', :action => 'top'

  map.users_default '/users/by/activity/:page', :controller => 'users', :action => 'index', :sort => 'active', :page => 1
  map.sorted_users '/users/by/:sort/:page', :controller => 'users', :action => 'index', :page => 1
  
  map.listens  ':login/history', :controller => 'listens'
  map.comments ':login/comments', :controller => 'comments'
   
  map.resources :users, :controller => :users, :member => {:attach_pic => :post, :sudo => :any} do |user|
    user.resources :tracks, :controller => :assets, :collection => {:latest => :get, :search => :post}, :path_prefix => ':login', :member_path => ':login/tracks/:id' do |track|
      track.resources :comments
    end
   
   # TODO - figure out a way to use :member_path with rails 2
   # http://dev.rubyonrails.org/changeset/8227
   # for now, i have to specify port to allow :permalink and :id to be sent at the same time
   user.resources :playlists, :collection => {:latest => :get}, :member=> {:set_playlist_title => :post, :set_playlist_description => :post, :attach_pic => :post, :remove_track => :any, :sort_tracks => :post, :add_track => :post},:path_prefix => ':login' do |playlist|
     playlist.resources :comments
   end
  end
  
  map.namespace(:admin) do |admin|
    admin.resources :layouts
    admin.resources :users
  end
  
  # Install the default route as the lowest priority.
  #map.connect ':controller/:action/:id'
  
  map.root :controller => 'assets', :action => 'latest'
  map.user_home ':login', :controller => 'users', :action => 'show'  
  map.user_feeds ':login.:format', :controller => 'users', :action => 'show'
  
end

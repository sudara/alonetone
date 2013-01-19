# -*- encoding : utf-8 -*-
Alonetone::Application.routes.draw do
  resources :groups

  match 'login' => 'user_sessions#new'
  match 'logout' => 'user_sessions#destroy'
  resources :user_sessions

  # admin stuff
  match 'secretz' => 'secretz#index'
  
  # one-off pages
  match 'rpmchallenge' => 'pages#rpm_challenge'
  match '24houralbum' =>  'pages#twentyfour'  
    
  resources :features, :sessions, :user_reports
  
  match 'blog' => 'updates#index', :as => "blog_home"
  
  resources 'updates', :as => 'blog'
  resources :updates
  resources :comments do
    member do 
      get :unspam 
    end
  end 
    

  match  'about/:action' => 'pages', :as => "about"
  match  'about/halp/:action' => 'pages', :as => "halp"
  
  
  match 'signup'    => 'users#new'
  match 'settings'  => 'users#edit'
  match 'login'     => 'sessions#create'
  match 'logout'    => 'sessions#destroy'
  match '/activate/:activation_code' => 'users#activate'


  # shortcut to profile
  match ':login/bio' => 'users#bio', :as => 'profile'
  
  match '/latest.:format' => 'assets#latest'
  
  # latest mp3s uploaded site-wide
  match '/latest/:latest' => 'assets#latest', :as => 'latest'
  
  match'/:login/listenfeed.:format' => 'assets#listen_feed', :as => 'listen_feed'
  
  match 'radio' =>'assets#radio', :as => 'radio_home'
  match 'radio/:source/:per_page/:page' => 'assets#radio', :defaults =>{:per_page => 5, :page => 1}, :as => 'radio'
  
  # top 40
  match  '/top/:top' => 'assets#top', :as => 'top'

  match '/users/by/activity/:page' => 'users#index', :sort => 'active', :defaults => {:page => 1}, :as => 'users_default'
  match '/users/by/:sort/:page' => 'users#index', :defaults => {:page => 1}, :as => 'sorted_users'
  
  match ':login/history' => 'listens#indexn', :as => 'listens'
  
  match 'comments' => 'comments#index', :as => 'all_comments'
  match ':login/comments' => 'comments#index', :as => 'user_comments'
  match ':login/stats.:format' => 'users#stats', :as => 'user_stats'
  
  match 'hot_track/:position.:format' => 'assets#hot_track', 
    :format     => 'mp3',
    :as => 'hot_track'
    
  match ':login/plus' => 'source_files#index', :as => 'user_plus'

  resources :forums do
    resources :topics do 
      resources :posts
    end
    resources :posts
  end
  
  resources :posts do
   collection do
      get :search
    end
  end

  
  match 'toggle_favorite' => 'users#toggle_favorite'
  
  match 'search' => 'search#index'
  match 'search/:query' => 'search#index', :as => 'search_query'

  namespace :admin do
    resources :layouts
    resources :users
  end
  
  
  root :to => 'assets#latest' 
  
  match ':login' => 'users#show', :as => "user_home"
  match ':login.:format' => 'users#show', :as => "user_feeds"
  
  resources :users, :path => "/" do
    member do
      post :attach_pic
      get :sudo
      get :toggle_follow
    end
    resources 'source_files' #:path_prefix => ':login'
    resources 'tracks', :controller => :assets do
      member do 
        get :share 
        get :stats
      end
      collection do
        get  :latest
        post :search
        get  :mass_edit 
      end
      resources :comments
    end
    resources :favorites
    resources :posts
    resources :playlists do
      collection do
        get :latest
        get :sort 
      end
      member do
        post :attach_pic
        get  :remove_track
        post :set_playlist_title
        post :set_playlist_description
        post :sort_tracks
        post :add_tracks
        get  :destroy
      end
      resources :comments
    end
   end
end

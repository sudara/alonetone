require 'sidekiq/web'
require 'admin_constraint'

Alonetone::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', :constraints => AdminConstraint.new

  constraints Greenfield::Constraints do
    mount Greenfield::Engine => "/"
  end

  constraints(->(req){ !Greenfield::Constraints.matches?(req) }) do
    resources :groups

    get '/login', :to => 'user_sessions#new', :as => 'login'
    match '/logout', :to => 'user_sessions#destroy', via: [:get, :post]
    resources :user_sessions

    # admin stuff
    get 'secretz' => 'secretz#index'

    get "/404", :to => "pages#four_oh_four"
    get '/500', :to => "pages#error"

    # one-off pages
    get 'rpmchallenge' => 'pages#rpm_challenge'
    get '24houralbum' =>  'pages#twentyfour'

    resources :features, :sessions, :user_reports

    get 'blog' => 'updates#index', :as => "blog_home"

    resources 'updates', :as => 'blog'
    resources :updates, :password_resets
    resources :comments do
      member do
        put :unspam
        put :spam
      end
    end

    get  'about/' => 'pages#index', :as => "about"
    get  'about/:action' => 'pages'
    get  'about/halp/:action' => 'pages', :as => "halp"

    get 'signup'    => 'users#new'
    get 'settings'  => 'users#edit'
    get '/activate/:perishable_token' => 'users#activate'


    # shortcut to profile
    get ':login/bio' => 'users#bio', :as => 'profile'

    get '/latest.:format' => 'assets#latest'

    # latest mp3s uploaded site-wide
    get '/latest/:latest' => 'assets#latest', :as => 'latest'

    get'/:login/listenfeed.:format' => 'assets#listen_feed', :as => 'listen_feed'

    get 'radio' =>'assets#radio', :as => 'radio_home'
    get 'radio/:source' => 'assets#radio', :defaults => {:per_page => 5, :page => 1}, :as => 'radio_source_home'
    get 'radio/:source/:per_page/:page' => 'assets#radio', :defaults => {:per_page => 5, :page => 1}, :as => 'radio'

    # top 40
    get  '/top/:top' => 'assets#top', :as => 'top'

    get '/users/by/activity/:page' => 'users#index', :sort => 'active', :defaults => {:page => 1}, :as => 'users_default'
    get '/users/(by/:sort(/:page))' => 'users#index', :defaults => {:page => 1}, :as => 'sorted_users'

    get ':login/history' => 'listens#index', :as => 'listens'

    get 'comments' => 'comments#index', :as => 'all_comments'
    get 'playlists' => 'playlists#all', :as => 'all_playlists'
    get ':login/comments' => 'comments#index', :as => 'user_comments'
    get ':login/stats.:format' => 'users#stats', :as => 'user_stats'

    get 'hot_track/:position.:format' => 'assets#hot_track',
        :format     => 'mp3',
        :as => 'hot_track'

    get ':login/plus' => 'source_files#index', :as => 'user_plus'

    resources :forums do
      resources :topics do
        resources :posts do
          member do
            put :unspam
            put :spam
          end
        end
      end
      resources :posts
    end

    resources :posts do
      collection do
        get :search
      end
    end


    get 'toggle_favorite' => 'users#toggle_favorite'

    match 'search' => 'search#index', via: [:get, :post]
    match 'search/:query' => 'search#index', :as => 'search_query', via: [:get, :post]

    namespace :admin do
      resources :layouts
      resources :users
    end


    root :to => 'assets#latest'

    resources :users
    get ':login' => 'users#show', :as => "user_home"
    get ':login.:format' => 'users#show', :as => "user_feeds"

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
          match :sort, :via => [:get, :post]
        end
        member do
          post :attach_pic
          get  :remove_track
          post :set_playlist_title
          post :set_playlist_description
          post :sort_tracks
          post :add_track
        end
        resources :comments
      end
    end
  end
end

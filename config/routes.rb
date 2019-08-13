require 'sidekiq/web'
require 'moderator_constraint'

Alonetone::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', :constraints => ModeratorConstraint.new
  constraints Greenfield::Constraints do
    mount Greenfield::Engine => "/"
  end

  namespace :admin do
    resources :users, path: 'users/(:filter_by)', only: [:index] do
      collection do
        get :stats
      end
      member do
        put :delete
        put :restore
        put :unspam
        put :spam
        put :mark_all_users_with_ip_as_spam
      end
    end
    resources :comments, path: 'comments/(:filter_by)', only: [:index] do
       member do
        put :unspam
        put :spam
      end
      collection do
        put :mark_group_as_spam
      end
    end
    resources :assets, path: 'assets/(:filter_by)', only: [:index] do
      member do
        put :unspam
        put :spam
      end
      collection do
        put :mark_group_as_spam
      end
    end
  end

  constraints(->(req){ !Greenfield::Constraints.matches?(req) }) do
    resources :groups

    mount Thredded::Engine => '/discuss'
    get '/upload', :to => 'assets#new'
    post '/listens', :to => 'listens#create', as: 'register_listen'
    get '/new_album', :to => 'playlists#new'
    get '/favorites', :to => 'playlists#favorites'
    get '/login', :to => 'user_sessions#new', :as => 'login'
    get '/logout', :to => 'user_sessions#destroy', as: 'logout', via: [:get, :post]
    resources :user_sessions

    get '/notifications/subscribe' => 'notifications#subscribe'
    get '/notifications/unsubscribe' => 'notifications#unsubscribe'

    get '/follow/:login' => 'following#follow', as: :follow
    get '/unfollow/:login' => 'following#unfollow', as: :unfollow
    get '/:login/toggle-follow' => 'following#toggle_follow', as: :toggle_follow

    # admin stuff
    get 'admin' => 'admin#index'
    get 'secretz' => 'admin#secretz'
    get 'toggle_theme' => 'admin#toggle_theme'

    get '404', to: "pages#four_oh_four"
    get '500', to: "pages#error"
    get 'ok', to: "pages#ok"

    # one-off pages
    get 'rpmchallenge' => 'pages#rpm_challenge'
    get '24houralbum' =>  'pages#twentyfour'

    resources :features

    get 'blog' => 'updates#index', :as => "blog_home"

    resources 'updates', :as => 'blog'
    resources :updates, :password_resets
    resources :comments

    get  'about/' => 'pages#about'

    %w(about press stats ok index privacy).each do |action|
      get "about/#{action}", to: "pages##{action}"
    end

    get 'signup', to: 'users#new'
    get 'settings', to: 'users#edit'
    get '/activate/:perishable_token', to: 'users#activate'

    get '/latest.:format' => 'assets#latest'

    # latest mp3s uploaded site-wide
    get '/latest/:latest' => 'assets#latest', :as => 'latest'

    get'/:login/listenfeed.:format' => 'assets#listen_feed', :as => 'listen_feed'

    get 'radio' =>'assets#radio', :as => 'radio_home'
    get 'radio/:source' => 'assets#radio', :as => 'radio_source_home'
    get 'radio/:source/:items' => 'assets#radio', :as => 'radio'

    # top 40
    get  '/top/:top' => 'assets#top', :as => 'top'

    get '/users/by/activity/:page' => 'users#index', :sort => 'active', :defaults => {:page => 1}, :as => 'users_default'
    get '/users/(by/:sort(/:page))' => 'users#index', :defaults => {:page => 1}, :as => 'sorted_users'

    get ':login/history' => 'listens#index', :as => 'listens'

    get 'comments' => 'comments#index', :as => 'all_comments'
    get 'playlists' => 'playlists#all', :as => 'all_playlists'
    get ':login/comments' => 'comments#index', :as => 'user_comments'
    get ':login/stats.:format' => 'users#stats', :as => 'user_stats'

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

    root :to => 'assets#latest'

    resources :users
    get ':login' => 'users#show', :as => "user_home"
    get ':login.:format' => 'users#show', :as => "user_feeds"

    resources :users, :path => "/" do
      member do
        post :attach_pic
        get :sudo
      end
      resource 'profile'
      resources 'source_files' #:path_prefix => ':login'
      resources 'tracks', controller: :assets do
        member do
          get :share
          get :stats
        end
        collection do
          get  :latest
          post :search
          get  :mass_edit
        end
        resources :comments,  only: [:create, :destroy]
      end
      resources :favorites
      resources :posts
      resources :playlists do
        collection do
          get :latest
          post :sort
          get :sort
        end
        member do
          post :attach_pic
          post :downloads, to: 'playlists#create_greenfield_download'
          get  :remove_track
          post :set_playlist_title
          post :set_playlist_description
          post :sort_tracks
          post :add_track
        end
        resources :comments
      end
      get '/playlists/:id/:asset_id', :to => 'playlists#show', as: 'show_track_in_playlist'
    end
  end

  if Rails.env.test?
    # Paperclip serves its files from the public directory, something that does't work well
    # with mocked uploaded files in feature specs. The files controller serves these files
    # so we don't have to muck around in the Rack middleware stack to solve this.
    get '/system/*path', to: 'test/files#show'
  end
end

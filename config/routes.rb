require 'sidekiq/web'
require 'moderator_constraint'

Alonetone::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', :constraints => ModeratorConstraint.new

  namespace :admin do
    get 'possibly_deleted_user/:id', :to => 'users#show', as: 'possibly_deleted_user'

    resources :account_requests, path: 'account_requests/(:filter_by)' do
      member do
        put :approve
        put :deny
      end
    end
    resources :users, path: 'users/(:filter_by)', only: [:index] do
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
    end
    resources :assets, path: 'assets/(:filter_by)', only: [:index] do
      member do
        put :unspam
        put :spam
        put :delete
        put :restore
      end
    end
    resources :mass_invites, param: :token
  end

  mount Thredded::Engine => '/forums'

  get '/get_an_account', :to => 'account_requests#new'
  resources 'account_requests', only: :create

  post '/get_an_account', :to => 'account_requests#create'
  get '/upload', :to => 'assets#new'
  post '/listens', :to => 'listens#create', as: 'register_listen'
  get '/new_album', :to => 'playlists#new'
  get '/favorites', :to => 'playlists#favorites'
  get '/login', :to => 'user_sessions#new', :as => 'login'
  get '/logout', :to => 'user_sessions#destroy', as: 'logout', via: [:get, :post]
  get '/notifications/subscribe' => 'notifications#subscribe'
  get '/notifications/unsubscribe' => 'notifications#unsubscribe'

  get '/follow/:login' => 'following#follow', as: :follow
  get '/unfollow/:login' => 'following#unfollow', as: :unfollow

  # admin stuff
  get 'admin' => 'admin#index'
  get 'secretz' => 'admin#secretz'
  put 'toggle_theme' => 'pages#toggle_theme'

  get '404', to: "pages#four_oh_four"
  get 'raise_error', to: 'pages#raise_error'
  get '500', to: "pages#error"
  get 'error', to: "pages#error"
  get 'ok', to: "pages#ok"

  # one-off pages
  get 'rpmchallenge' => 'pages#rpm_challenge'
  get '24houralbum' =>  'pages#twentyfour'

  resources :password_resets, :comments, :user_sessions, :groups

  get 'about/' => 'pages#about'
  get 'about/why-i-built-alonetone' => 'pages#why'
  %w(about press stats ok help privacy faq).each do |action|
    get "about/#{action}", to: "pages##{action}"
  end

  get 'signup', to: 'users#new'
  get '/activate/:perishable_token', to: 'users#activate'

  get 'radio' =>'assets#radio', :as => 'radio_home'
  get 'radio/:source' => 'assets#radio', :as => 'radio_source_home'
  get 'radio/:source/:items' => 'assets#radio', :as => 'radio'

  # top 40
  get  '/top/:top' => 'assets#top', :as => 'top'

  get 'comments' => 'comments#index', :as => 'all_comments'
  get 'playlists' => 'playlists#all', :as => 'all_playlists'

  get 'toggle_favorite' => 'users#toggle_favorite'

  match 'search' => 'search#index', via: [:get, :post]
  match 'search/:query' => 'search#index', :as => 'search_query', via: [:get, :post]

  root :to => 'assets#latest'

  get '/users', to: redirect('/users/by/last_seen/1')
  resources :users

  # unless we have the /by/ in the route, we end up in conflict with the resource route
  get '/users/by/:sort/(:page)' => 'users#index', :as => 'sorted_users'

  get '/invite/:mass_invite_token', to: 'mass_invites_users#new', as: 'mass_invite'
  resources :mass_invites, param: :token, only: [] do
    resource :users, only: %i[new create show], controller: :mass_invites_users
  end

  get ':login/history' => 'listens#index', :as => 'listens'
  get ':login/comments' => 'comments#index', :as => 'user_comments'
  get '/:login/toggle-follow' => 'following#toggle_follow', as: :toggle_follow

  get ':id' => 'users#show', :as => "user_home" # DEPRECATED (duplicate)
  resources :users, :path => "/" do
    member do
      post :attach_pic
      get :sudo
      put :toggle_setting
    end
    resource 'profile'
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
    resources :playlists do
      collection do
        get :latest
        post :sort
        get :sort
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
    get '/playlists/:id/:asset_id', :to => 'playlists#show', as: 'show_track_in_playlist'
  end
end

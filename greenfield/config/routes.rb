Greenfield::Engine.routes.draw do
  root to: 'pages#home'
  get "/404" => "pages#not_found"

  post 'login', to: 'application#login', as: :user_sessions

  resources :user, path: '/', only: [] do
    resources :posts, path: 'tracks', only: [:show, :edit, :update] do
      resources :attached_assets, :only => [:show, :create]
      post :listens, to: 'posts#create_listen'
    end

    get 'playlists/:playlist_id', :to => 'playlists#show', :as => :playlist
    get 'playlists/:playlist_id/downloads/:download_id/:download_name', to: 'playlist_downloads#serve', as: :playlist_download
    get 'playlists/:playlist_id/:asset_id', :to => 'playlists#show', :as => :playlist_post
    get 'playlists/:playlist_id/:asset_id/edit', :to => 'posts#edit', :as => :edit_playlist_post
    post 'playlists/:playlist_id/:asset_id/listens', :to => 'playlists#create_listen'
  end
end

Greenfield::Engine.routes.draw do
  root to: 'application#nothing'

  post 'login', to: 'application#login', as: :user_sessions

  resources :user, path: '/', only: [] do
    resources :posts, path: 'tracks', only: [:show, :edit, :update] do
      resources :attached_assets, :only => [:show, :create]
    end

    get 'playlists/:playlist_id', :to => 'posts#show', :as => :playlist
    get 'playlists/:playlist_id/:position', :to => 'posts#show', :as => :playlist_position
  end
end

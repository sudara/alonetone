Greenfield::Engine.routes.draw do
  resources :posts, :only => [:show, :edit, :update] do
    resources :attached_assets, :only => [:show, :create]
  end

  resources :playlists, :only => [:index, :create, :edit] do
    member do
      post :posts, :action => 'create_post'
      put :posts, :action => 'replace_all_posts'
      delete :posts, :action => 'destroy_post'
    end
  end

  get 'playlists/:playlist_id', :to => 'posts#show', :as => :playlist
  get 'playlists/:playlist_id/:position', :to => 'posts#show', :as => :playlist_position
end

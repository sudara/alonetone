Greenfield::Engine.routes.draw do
  resources :posts, :only => [:show, :edit, :update] do
    resources :attached_assets, :only => [:show, :create]
  end
end

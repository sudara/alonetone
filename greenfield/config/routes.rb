Greenfield::Engine.routes.draw do
  resources :posts, :only => [:new, :show, :create] do
    resources :attached_assets, :only => :show
  end
end

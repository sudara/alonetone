Greenfield::Engine.routes.draw do
  resources :users, :path => '/' do
    resources :posts, :path => '/', :only => [:new, :show, :edit, :create, :update] do
      resources :attached_assets, :only => :show
    end
  end
end

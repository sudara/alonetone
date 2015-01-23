Greenfield::Engine.routes.draw do
  resources :posts, :only => [:new, :show, :create]
end

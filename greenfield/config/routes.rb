Greenfield::Engine.routes.draw do
  resources :posts, :only => [:show]
end

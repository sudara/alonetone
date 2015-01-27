Greenfield::Engine.routes.draw do
  scope :path => ':user_id', :as => 'user' do
    resources :posts, :path => '/', :only => [:show, :edit, :update] do
      resources :attached_assets, :only => :show
    end
  end
end

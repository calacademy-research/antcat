ActionController::Routing::Routes.draw do |map|
  map.root :controller => "references"

  map.resources :references, :only => [:index, :update, :create, :destroy]
  map.resources :journals, :only => [:index]

  map.devise_for :users
end

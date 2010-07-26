ActionController::Routing::Routes.draw do |map|
  map.resources :references
  map.root :controller => "references"

  map.resources :journals
end

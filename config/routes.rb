ActionController::Routing::Routes.draw do |map|
  map.resources :references
  map.root :controller => "references"
end

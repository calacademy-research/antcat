ActionController::Routing::Routes.draw do |map|
  map.resources :references
  map.root :controller => "references"

  map.resources :autofill_demos
end

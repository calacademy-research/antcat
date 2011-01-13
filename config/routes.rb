ActionController::Routing::Routes.draw do |map|
  map.root :controller => "references"

  map.devise_for :users

  map.resources :references, :only => [:index, :update, :create, :destroy],
                :has_many => :duplicate_references
  map.resources :journals, :only => [:index]
  map.resources :authors, :only => [:index]
  map.resources :bolton_matches, :only => [:index]
  map.resources :duplicate_references, :only => [:index]
  map.resources :publishers, :only => [:index]
  map.resources :species, :only => [:index]

  map.resources :taxatry, :singular => 't'

  map.connect '/documents/:id/:file_name.:ext', :controller => :references, :action => :download,
    :conditions => {:method => :get}
end

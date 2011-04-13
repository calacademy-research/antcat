ActionController::Routing::Routes.draw do |map|
  map.root :controller => "taxatry"

  map.devise_for :users

  map.resources :references, :only => [:index, :update, :create, :destroy],
                :has_many => :duplicate_references
  map.resources :journals
  map.resources :authors, :only => [:index]
  map.resources :bolton_matches, :only => [:index]
  map.resources :duplicate_references, :only => [:index]
  map.resources :publishers, :only => [:index]
  map.resources :species, :only => [:index]
  map.resources :styles, :only => [:index]

  map.resources :taxatry, :singular => 'taxon', :only => [:index, :show]
  map.resources :forager, :only => [:index]

  map.connect '/documents/:id/:file_name', :controller => :references, :action => :download, :file_name => /.+/,
    :conditions => {:method => :get}
end

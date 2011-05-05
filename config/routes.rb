AntCat::Application.routes.draw do

  root :to => "taxatry/browser#show"

  resources :authors, :only => [:index]
  resources :bolton_matches, :only => [:index]
  match     '/documents/:id/:file_name', :to => 'references#download', :file_name => /.+/, :via => :get
  resources :duplicate_references, :only => [:index]
  resources :journals
  resources :publishers, :only => [:index]
  resources :references, :only => [:index, :update, :create, :destroy] do
    resources :duplicate_references
  end
  resources :species, :only => [:index]
  resources :styles, :only => [:index]
  resource  :taxatry, :only => [] do
    match     'index/(:id)', :to => 'taxatry/index#show', :as => 'index'
    match     'browser/(:id)', :to => 'taxatry/browser#show', :as => 'browser'
  end
  devise_for :users

end

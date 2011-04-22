AntCat::Application.routes.draw do

  root :to => "taxatry#show"

  resources :authors, :only => [:index]
  resources :bolton_matches, :only => [:index]
  match     '/documents/:id/:file_name', :to => 'references#download', :file_name => /.+/, :via => :get
  resources :duplicate_references, :only => [:index]
  match     'forager/(:id)', :to => 'forager#show', :as => 'forager'
  resources :journals
  resources :publishers, :only => [:index]
  resources :references, :only => [:index, :update, :create, :destroy] do
    resources :duplicate_references
  end
  resources :species, :only => [:index]
  resources :styles, :only => [:index]
  match     'taxatry/(:id)', :to => 'taxatry#show', :as => 'taxatry'

  devise_for :users

end

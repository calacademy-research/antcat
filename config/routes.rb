AntCat::Application.routes.draw do

  root :to => "taxatry#index"

  resources :authors, :only => [:index]
  resources :bolton_matches, :only => [:index]
  match     '/documents/:id/:file_name', :to => 'references#download', :file_name => /.+/, :via => :get
  resources :duplicate_references, :only => [:index]
  resources :forager, :only => [:index]
  resources :journals
  resources :publishers, :only => [:index]
  resources :references, :only => [:index, :update, :create, :destroy] do
    resources :duplicate_references
  end
  resources :species, :only => [:index]
  resources :styles, :only => [:index]
  match     'taxatry', :to => 'taxatry#index', :as => 'taxatry'
  match     'taxon/:id', :to => 'taxatry#show', :as => 'taxon'

  devise_for :users

end

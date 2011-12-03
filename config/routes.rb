# coding: UTF-8
AntCat::Application.routes.draw do

  root :to => "catalog/index#show"

  resources :authors, :only => [:index]
  resources :bolton_references, :only => [:index]
  match     '/documents/:id/:file_name', :to => 'references#download', :file_name => /.+/, :via => :get
  resources :duplicate_references, :only => [:index]
  resources :journals
  resources :publishers, :only => [:index]
  resources :references, :only => [:index, :update, :create, :destroy] do
    resources :duplicate_references
  end
  match     '/antcat_references.utf8.endnote_import', :to => 'references#index', :format => :endnote_import, :as => :endnote_import
  resources :species, :only => [:index]
  resources :styles, :only => [:index]
  resource  :catalog, :only => [] do
    match     'index/(:id)', :to => 'catalog/index#show', :as => 'index'
    match     'browser/(:id)', :to => 'catalog/browser#show', :as => 'browser'
  end

  devise_for :users

end

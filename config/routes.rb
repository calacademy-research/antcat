# coding: UTF-8
require 'release_type'

AntCat::Application.routes.draw do

  root to: "catalog/index#show"

  resources :authors, only: [:index, :all, :merge]
  match     '/authors/all', to: 'authors#all', via: :get
  match     '/authors/merge', to: 'authors#merge', via: :post
  resources :bolton_references
  resource  :catalog, only: [] do
    match     'index/(:id)', to: 'catalog/index#show', as: 'index'
    match     'browser/(:id)', to: 'catalog/browser#show', as: 'browser'
  end
  match     '/documents/:id/:file_name', to: 'references#download', file_name: /.+/, via: :get
  resources :journals
  resources :publishers, only: [:index]
  resources :references, only: [:index, :update, :create, :destroy]
  match     '/antcat_references.utf8.endnote_import', to: 'references#index', format: :endnote_import, as: :endnote_import
  resources :styles, only: [:index]

  resources :families, controller: :taxa do
    resources :taxonomic_history_items
  end

  devise_for :users

end

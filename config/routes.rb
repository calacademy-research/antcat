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

  resources :families, controller: :catalog do
    resources :taxonomic_history_items
  end
  resources :subfamilies, controller: :catalog do
    resources :taxonomic_history_items
  end
  resources :tribes, controller: :catalog do
    resources :taxonomic_history_items
  end
  resources :genera, controller: :catalog do
    resources :taxonomic_history_items
  end
  resources :subgenera, controller: :catalog do
    resources :taxonomic_history_items
  end
  resources :species, controller: :catalog do
    resources :taxonomic_history_items
  end
  resources :subspecies, controller: :catalog do
    resources :taxonomic_history_items
  end

  resources :reference_pickers

  match '/widget_tests/reference_picker', to: 'widget_tests#reference_picker'

  devise_for :users

end

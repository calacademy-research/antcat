# coding: UTF-8
require 'release_type'

AntCat::Application.routes.draw do

  root to: 'catalog#show'

  resources :authors, only: [:index, :all, :merge]
  match     '/authors/all', to: 'authors#all', via: :get
  match     '/authors/merge', to: 'authors#merge', via: :post

  match     'catalog/index/(:id)' => 'catalog#show', as: :catalog, via: :get # for compatibility
  match     'catalog/search' => 'catalog#search', as: :catalog, via: :get
  match     'catalog/show_unavailable_subfamilies', as: :catalog, via: :get
  match     'catalog/hide_unavailable_subfamilies', as: :catalog, via: :get
  match     'catalog/show_tribes' => 'catalog#show_tribes', as: :catalog, via: :get
  match     'catalog/hide_tribes' => 'catalog#hide_tribes', as: :catalog, via: :get
  match     'catalog/show_subgenera' => 'catalog#show_subgenera', as: :catalog, via: :get
  match     'catalog/hide_subgenera' => 'catalog#hide_subgenera', as: :catalog, via: :get
  match     'catalog/(:id)' => 'catalog#show', as: :catalog, via: :get

  match     '/catalog/:id/reverse_synonymy' => 'catalog#reverse_synonymy'
  match     '/catalog/:id/elevate_subspecies' => 'catalog#elevate_subspecies'

  resources :bolton_references
  match     '/documents/:id/:file_name', to: 'references#download', file_name: /.+/, via: :get
  resources :journals
  resources :publishers, only: [:index]
  resources :references, only: [:index, :update, :create, :destroy]
  match     '/antcat_references.utf8.endnote_import', to: 'references#index', format: :endnote_import, as: :endnote_import
  resources :styles, only: [:index]

  resources :taxa, controller: :taxa

  resource :taxon_window_height, only: [:update]

  resources :name_pickers, only: [:index, :lookup]

  get 'name_popups/search'
  get 'name_popups/find'
  match 'name_popups/:id' => 'name_popups#show'

  match 'name_pickers/lookup' => 'name_pickers#lookup', as: :name_picker, via: :get
  resource :reference_picker, only: :show
  resource :reference_popup, only: :show
  resource :name_picker, only: :show

  match '/widget_tests/name_picker_test', to: 'widget_tests#name_picker_test'
  match '/widget_tests/name_popup_test', to: 'widget_tests#name_popup_test'
  match '/widget_tests/name_field_test', to: 'widget_tests#name_field_test'
  match '/widget_tests/reference_picker_test', to: 'widget_tests#reference_picker_test'
  match '/widget_tests/reference_popup_test', to: 'widget_tests#reference_popup_test'
  match '/widget_tests/reference_field_test', to: 'widget_tests#reference_field_test'
  match '/widget_tests/taxt_editor_test', to: 'widget_tests#taxt_editor_test'

  devise_for :users

end

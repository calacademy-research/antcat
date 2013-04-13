# coding: UTF-8
AntCat::Application.routes.draw do

  root to: 'catalog#show'

  resources :authors, only: [:index, :all, :merge]
  match     '/authors/all', to: 'authors#all', via: :get
  match     '/authors/merge', to: 'authors#merge', via: :post

  match     'catalog/index/(:id)'    => 'catalog#show',           as: :catalog, via: :get # for compatibility
  match     'catalog/search'         => 'catalog#search',         as: :catalog, via: :get
  match     'catalog/show_unavailable_subfamilies',               as: :catalog, via: :get
  match     'catalog/hide_unavailable_subfamilies',               as: :catalog, via: :get
  match     'catalog/show_tribes'    => 'catalog#show_tribes',    as: :catalog, via: :get
  match     'catalog/hide_tribes'    => 'catalog#hide_tribes',    as: :catalog, via: :get
  match     'catalog/show_subgenera' => 'catalog#show_subgenera', as: :catalog, via: :get
  match     'catalog/hide_subgenera' => 'catalog#hide_subgenera', as: :catalog, via: :get
  match     'catalog/(:id)'          => 'catalog#show',           as: :catalog, via: :get

  resources :bolton_references
  match     '/documents/:id/:file_name', to: 'references#download', file_name: /.+/, via: :get
  resources :journals
  resources :publishers, only: [:index]

  resources :references, only: [:index, :update, :create, :destroy]

  match     '/antcat_references.utf8.endnote_import', to: 'references#index', format: :endnote_import, as: :endnote_import

  match '/taxa/:id' => redirect('/catalog/%{id}')
  resources :taxa do
    resources 'taxon_history_items', only: [:update, :create, :destroy]
    resources 'synonyms', only: [:create, :destroy] do
      member do
        put 'reverse_synonymy'
      end
    end
    member do
      get 'elevate_to_species'
    end
  end

  resource :taxon_window_height, only: [:update]

  get 'name_pickers/search'

  get 'name_popups/find'
  match 'name_popups/:type/:id' => 'name_popups#show', via: :get

  get 'name_fields/find'
  match 'name_fields/:type/:id' => 'name_fields#show', via: :get

  resource :reference_field, only: :show
  resource :reference_popup, only: :show

  match '/widget_tests/name_popup_test', to: 'widget_tests#name_popup_test'
  match '/widget_tests/name_field_test', to: 'widget_tests#name_field_test'
  match '/widget_tests/reference_popup_test', to: 'widget_tests#reference_popup_test'
  match '/widget_tests/reference_field_test', to: 'widget_tests#reference_field_test'
  match '/widget_tests/taxt_editor_test', to: 'widget_tests#taxt_editor_test'

  resources :changes, controller: 'paper_trail_manager/changes'

  devise_for :users

end

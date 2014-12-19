# coding: UTF-8
AntCat::Application.routes.draw do

  root to: 'catalog#show'

  resources :changes, only: [:show, :index] do
    member do
      put :approve
    end
  end

  resources :authors, only: [:index, :edit, :update] do
    resources :author_names, only: [:update, :create, :destroy]
  end
  resources :merge_authors, only: [:index, :merge]
  match     '/merge_authors/merge', to: 'merge_authors#merge', via: :post

  match     'catalog/index/(:id)'    => 'catalog#show',             via: :get # for compatibility
  match     'catalog/search'         => 'catalog#search',           via: :get
  match     'catalog/show_unavailable_subfamilies',                 via: :get
  match     'catalog/hide_unavailable_subfamilies',                 via: :get
  match     'catalog/show_tribes'    => 'catalog#show_tribes',      via: :get
  match     'catalog/hide_tribes'    => 'catalog#hide_tribes',      via: :get
  match     'catalog/show_subgenera' => 'catalog#show_subgenera',   via: :get
  match     'catalog/hide_subgenera' => 'catalog#hide_subgenera',   via: :get
  match     'catalog/(:id)'          => 'catalog#show',             as: :catalog, via: :get

  resources :bolton_references, only: [:index, :update]
  match     '/documents/:id/:file_name', to: 'references#download', file_name: /.+/, via: :get
  resources :journals, only: [:index, :show, :new, :create, :edit, :update]
  resources :publishers, only: [:index]

  resources :references, only: [:index, :update, :create, :destroy] do
    member do
      post 'start_reviewing'
      post 'finish_reviewing'
      post 'restart_reviewing'
    end
  end
  resources :missing_references, only: [:index, :edit, :update]

  match     '/antcat_references.utf8.endnote_import', to: 'references#index', format: :endnote_import, as: :endnote_import, via: :get

  resources :taxa do
    resources 'taxon_history_items', only: [:update, :create, :destroy]
    resources 'reference_sections', only: [:update, :create, :destroy]
    resources 'synonyms', only: [:create, :destroy] do
      member do
        put 'reverse_synonymy'
      end
    end
    resource 'convert_to_subspecies', only: [:new, :create]
  end

  resource :advanced_search, only: [:show]
  resource :default_reference, only: [:update]
  resource :taxon_window_height, only: [:update, :show]

  get 'name_pickers/search'

  get 'name_popups/find'
  match 'name_popups/:type/:id' => 'name_popups#show', via: :get

  get 'name_fields/find'
  match 'name_fields/:type/:id' => 'name_fields#show', via: :get


  resource :reference_field, only: [:show]
  resource :reference_popup, only: [:show]
  resource :duplicates, only: [:show,:create]

  match '/widget_tests/name_popup_test', to: 'widget_tests#name_popup_test',via: [:get]
  match '/widget_tests/name_field_test', to: 'widget_tests#name_field_test',via: [:get]
  match '/widget_tests/reference_popup_test', to: 'widget_tests#reference_popup_test',via: [:get]
  match '/widget_tests/reference_field_test', to: 'widget_tests#reference_field_test',via: [:get]
  match '/widget_tests/taxt_editor_test', to: 'widget_tests#taxt_editor_test',via: [:get]

  match '/paper_trail', to: 'paper_trail_manager/changes#index', via: :get

  devise_for :users
  resources :users

  namespace :api, defaults: {format: :json} do
    resources :taxa
  end

end

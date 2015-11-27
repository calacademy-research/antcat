# coding: UTF-8
AntCat::Application.routes.draw do

  ActiveAdmin.routes(self)
  root to: 'catalog#show'

  resources :changes, only: [:show, :index] do
    member do
      put :approve
      put :undo
      get :undo_items
    end

  end
  match 'changes/approve_all' => 'changes#approve_all', as: :changes_approve_all, via: :put



  resources :authors, only: [:index, :edit, :update] do
    resources :author_names, only: [:update, :create, :destroy]
  end
  resources :merge_authors, only: [:index, :merge]
  match '/merge_authors/merge', to: 'merge_authors#merge', via: :post

  match 'catalog/index/(:id)' => 'catalog#show', as: :catalog_index, via: :get # for compatibility
  match 'catalog/search' => 'catalog#search', as: :catalog_search, via: :get
  match 'catalog/show_unavailable_subfamilies', as: :catalog_show_subfamilies, via: :get
  match 'catalog/hide_unavailable_subfamilies', as: :catalog_hide_subfamilies, via: :get
  match 'catalog/show_tribes' => 'catalog#show_tribes', as: :catalog_show_tribes, via: :get
  match 'catalog/hide_tribes' => 'catalog#hide_tribes', as: :catalog_hide_tribes, via: :get
  match 'catalog/show_subgenera' => 'catalog#show_subgenera', as: :catalog_show_subgenera, via: :get
  match 'catalog/hide_subgenera' => 'catalog#hide_subgenera', as: :catalog_hide_subgenera, via: :get
  match 'catalog/(:id)' => 'catalog#show', as: :catalog, via: :get
  match 'catalog/delete_impact_list/(:id)' => 'catalog#delete_impact_list', as: :catalog_delete_impact_list, via: :get


  resources :bolton_references, only: [:index, :update]
  match '/documents/:id/:file_name', to: 'references#download', file_name: /.+/, via: :get
  resources :journals, only: [:index, :show, :new, :create, :edit, :update]
  resources :publishers, only: [:index]

  resources :references, only: [:index, :update, :create, :destroy] do
    member do
      post 'start_reviewing'
      post 'finish_reviewing'
      post 'restart_reviewing'
    end
  end
  match 'references/approve_all' => 'references#approve_all', as: :approve_all, via: :get
  resources :missing_references, only: [:index, :edit, :update]

  match '/antcat_references.utf8.endnote_import', to: 'references#index', format: :endnote_import, as: :endnote_import, via: :get

  resources :taxa do
    resources 'taxon_history_items', only: [:update, :create, :destroy]
    resources 'reference_sections', only: [:update, :create, :destroy]
    resources 'synonyms', only: [:create, :destroy] do
      member do
        put 'reverse_synonymy'
      end
    end
    resource 'convert_to_subspecies', only: [:new, :create]
    #resource 'update_parent', only: [:update, :index]

    match 'delete' => 'taxa#delete', as: :taxa, via: :get # for compatibility
    #get 'update_parent', to: :update_parent
  end
  match '/taxa/:taxon_id/update_parent/:new_parent_taxon_id', :controller => 'taxa', action: 'update_parent', via: :get


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
  resource :duplicates, only: [:show, :create]

  # These are shortcuts to support the tests in
  match '/widget_tests/name_popup_test', to: 'widget_tests#name_popup_test', via: :get
  match '/widget_tests/name_field_test', to: 'widget_tests#name_field_test', via: :get
  match '/widget_tests/reference_popup_test', to: 'widget_tests#reference_popup_test', via: :get
  match '/widget_tests/reference_field_test', to: 'widget_tests#reference_field_test', via: :get
  match '/widget_tests/taxt_editor_test', to: 'widget_tests#taxt_editor_test', via: :get

  devise_for :users, :controllers => { :invitations => 'users/invitations' }
  resources :users, only: [:index]

  namespace :api, defaults: {format: :json} do
    resources :taxa
  end

  resources :antweb_data, only: [:index]

  # REST
  resources :taxon, :controller => 'taxa', :except => [:edit, :new, :update, :destroy]


end

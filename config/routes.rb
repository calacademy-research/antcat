AntCat::Application.routes.draw do

  ActiveAdmin.routes(self)
  root to: 'catalog#show'

  resources :changes, only: [:show, :index] do
    collection do
      put 'approve_all'
    end
    member do
      put :approve
      put :undo
      get :undo_items
    end
  end

  resources :authors, only: [:index, :edit, :update] do
    resources :author_names, only: [:update, :create, :destroy]
  end
  resources :merge_authors, only: [:index, :merge]
  match '/merge_authors/merge', to: 'merge_authors#merge', via: :post

  namespace "catalog" do
    get 'search'
    get 'show_unavailable_subfamilies'
    get 'hide_unavailable_subfamilies'
    get 'show_tribes'
    get 'hide_tribes'
    get 'show_subgenera'
    get 'hide_subgenera'
  end

  # TODO remove?
  match 'catalog/index/(:id)' => 'catalog#show', as: :catalog_index, via: :get # for compatibility
  match 'catalog/(:id)' => 'catalog#show', as: :catalog, via: :get
  # TODO move to TaxaController
  match 'catalog/delete_impact_list/(:id)' => 'catalog#delete_impact_list', as: :catalog_delete_impact_list, via: :get

  resources :bolton_references, only: [:index, :update]
  match '/documents/:id/:file_name', to: 'references#download', file_name: /.+/, via: :get
  resources :journals, only: [:index, :show, :new, :create, :edit, :update]
  resources :publishers, only: [:index]

  resources :references do
    collection do
      get 'search'
      get 'autocomplete'
      get 'latest_additions'
      get 'latest_changes'
      get 'endnote_export'
      put 'approve_all'
    end
    member do
      post 'start_reviewing'
      post 'finish_reviewing'
      post 'restart_reviewing'
      get  'endnote_export'
    end
  end
  resources :missing_references, only: [:index, :edit, :update]

  resources :taxa do
    collection do
      get 'autocomplete'
    end
    resources 'taxon_history_items', only: [:update, :create, :destroy]
    resources 'reference_sections', only: [:update, :create, :destroy]
    resources 'synonyms', only: [:create, :destroy] do
      member do
        put 'reverse_synonymy'
      end
    end
    resource 'convert_to_subspecies', only: [:new, :create]
    #resource 'update_parent', only: [:update, :index]
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

  devise_for :users, :controllers => { :invitations => 'users/invitations' }
  resources :users, only: [:index]

  resources :antweb_data, only: [:index]

  resources :tooltips, only: [:index, :show, :new, :edit, :create, :update, :destroy] do
    collection do
      get 'enabled_selectors'
    end
  end

  # REST
  resources :taxon, :controller => 'taxa', :except => [:edit, :new, :update, :destroy]

  unless Rails.env.production?
    namespace "widget_tests" do
      get 'name_popup_test'
      get 'name_field_test'
      get 'reference_popup_test'
      get 'reference_field_test'
      get 'taxt_editor_test'
    end
  end

end

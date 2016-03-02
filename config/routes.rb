AntCat::Application.routes.draw do

  ActiveAdmin.routes(self)
  root to: 'catalog#index'

  resources :changes, only: [:show, :index] do
    collection do
      get :unreviewed
      put :approve_all
    end
    member do
      put :approve
      put :undo
      get :undo_items
    end
  end

  resources :authors, only: [:index, :edit, :update] do
    collection do
      get :autocomplete
    end
    resources :author_names, only: [:update, :create, :destroy]
  end
  resources :merge_authors, only: [:index, :merge]
  post '/merge_authors/merge', to: 'merge_authors#merge'

  namespace :catalog do
    get :search
    get :options
  end

  # TODO remove?
  get 'catalog/index/:id' => 'catalog#show' # for compatibility
  get 'catalog/:id' => 'catalog#show', as: :catalog

  get '/documents/:id/:file_name', to: 'references#download', file_name: /.+/
  resources :journals, only: [:index, :show, :new, :create, :edit, :update] do
    collection do
      get :autocomplete
    end
  end

  namespace :publishers do
    get :autocomplete
  end

  resources :references do
    collection do
      get :search
      get :autocomplete
      get :latest_additions
      get :latest_changes
      get :endnote_export
      put :approve_all
    end
    member do
      post :start_reviewing
      post :finish_reviewing
      post :restart_reviewing
      get :endnote_export
    end
  end
  resources :missing_references, only: [:index, :edit, :update]

  resources :taxa do
    collection do
      get :autocomplete
    end
    member do
      get :delete_impact_list
      get :update_parent # TODO change to put
      put :elevate_to_species
      delete :destroy_unreferenced
    end
    resources :taxon_history_items, only: [:update, :create, :destroy]
    resources :reference_sections, only: [:update, :create, :destroy]
    resources :synonyms, only: [:create, :destroy] do
      member do
        put :reverse_synonymy
      end
    end
    resource :convert_to_subspecies, only: [:new, :create]
  end

  resource :advanced_search, only: [:show]
  resource :default_reference, only: [:update]

  get 'name_pickers/search'

  get 'name_popups/find'
  get 'name_popups/:type/:id' => 'name_popups#show'

  get 'name_fields/find'
  get 'name_fields/:type/:id' => 'name_fields#show'

  resource :reference_field, only: [:show]
  resource :reference_popup, only: [:show]
  resource :duplicates, only: [:show, :create]

  devise_for :users, controllers: { invitations: 'users/invitations' }
  resources :users, only: [:index]

  scope module: 'api' do
    namespace :v1 do
      resources :taxa
      get '/taxa/search/:string', to: 'taxa#search'
      resources :protonyms
      resources :authors
      resources :author_names
      resources :names
      resources :citations
      resources :taxon_history_items
      resources :journals
      resources :places
      resources :publishers
      resources :references
      resources :reference_author_names
      resources :reference_documents
      resources :reference_sections
      resources :synonyms
    end
    # For the next version...
    # namespace :v2 do
    #   resources :taxa
    # end
  end

  resources :antweb_data, only: [:index]

  get "panel", to: "editors_panels#index", as: "editors_panel"

  resources :tooltips do
    collection do
      get :enabled_selectors
      get :render_missing_tooltips
      get :toggle_tooltip_helper
    end
  end

  # REST
  resources :taxon, controller: 'taxa', except: [:edit, :new, :update, :destroy]

  unless Rails.env.production?
    namespace :widget_tests do
      get :name_popup_test
      get :name_field_test
      get :reference_popup_test
      get :reference_field_test
      get :taxt_editor_test
      get :tooltips_test
    end
  end

end

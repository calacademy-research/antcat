Rails.application.routes.draw do
  root to: 'catalog#index'

  mount SwaggerUiEngine::Engine, at: "/api_docs"

  resources :changes, only: [:show, :index] do
    collection do
      get :unreviewed
      put :approve_all
    end

    member do
      put :approve
    end

    scope module: :changes do
      resource :undos, only: [:show, :create]
    end
  end

  resources :authors, only: [:index, :show] do
    collection do
      get :autocomplete
    end
    resources :author_names, except: [:show, :index], shallow: true
  end
  resources :merge_authors, only: [:index, :merge]
  post '/merge_authors/merge', to: 'merge_authors#merge'

  namespace :catalog do
    get :autocomplete
    get :show_invalid
    get :show_valid_only
    get "random", to: "random#show"
    get "fix_random", to: "fix_random#show"
    get "search", to: "search#index"
    get "search/quick_search", to: "search#quick_search", as: "quick_search"
  end
  get 'catalog/:id' => 'catalog#show', as: :catalog
  get 'catalog/:id/wikipedia' => 'catalog/wikipedia#show'
  get 'catalog/:id/tab/:tab_id' => 'catalog#tab', as: :catalog_tab
  get 'catalog/:id/history' => 'catalog/history#show', as: :taxon_history
  get 'catalog/:id/what_links_here' => 'catalog/what_links_here#index', as: :taxon_what_links_here

  get '/documents/:id/:file_name', to: 'references/downloads#show', file_name: /.+/

  resources :institutions

  resources :journals do
    collection do
      get :autocomplete
      get :linkable_autocomplete
    end
  end

  namespace :publishers do
    get :autocomplete
  end

  resources :references do
    collection do
      get :autocomplete
      get :linkable_autocomplete
    end

    scope module: :references do
      resources :history, only: :index
      resources :what_links_here, only: :index

      member do
        scope :reviews, controller: :reviews, as: :reviewing do
          post :start
          post :finish
          post :restart
        end

        scope :exports, controller: :exports, as: :export do
          get :wikipedia
        end
      end

      collection do
        scope :exports, controller: :exports, as: :export do
          get :endnote
        end

        resources :latest_additions, only: :index, as: :references_latest_additions
        resources :latest_changes, only: :index, as: :references_latest_changes

        scope :reviews, controller: :reviews, as: :reviewing do
          put :approve_all
        end

        resources :search, only: :index, as: :references_search do
          get :help, on: :collection
        end
      end
    end
  end

  resources :protonyms, only: [:index, :show, :destroy]
  scope module: :protonyms do
    scope controller: :localities, path: "/protonyms/localities" do
      get :autocomplete
    end
  end

  resources :taxa, only: [:new, :create, :edit, :update] do
    member do
      controller :taxa_grab_bag do
        get :confirm_before_delete
        delete :destroy
        delete :destroy_unreferenced
      end
    end
    resources :taxon_history_items, only: [:new, :create]
    resources :reference_sections, only: [:new, :create]
    resources :synonyms, only: [:create, :destroy] do
      member do
        put :reverse_synonymy
      end
    end
    scope module: :taxa do
      resource :children, only: [:show]
      resource :create_combination, only: [:new, :show]
      resource :convert_to_subspecies, only: [:new, :create]
      resource :force_parent_change, only: [:show, :create]
      resource :elevate_to_species, only: [:create]
      resource :create_obsolete_combination, only: [:show, :create]
      resource :move_items, only: [:new, :show, :create]
      resource :reorder_history_items, only: [:create]
    end
  end

  resource :default_reference, only: :update

  get 'name_pickers/search'
  get 'name_fields/find'
  get 'name_fields/:type/:id' => 'name_fields#show'

  devise_for :users, path_prefix: 'my', controllers: { registrations: "registrations" }
  resources :users, only: [:index, :show, :new, :create, :edit, :update] do
    collection do
      get :mentionables
    end
  end

  scope module: 'api' do
    namespace :v1 do
      resources :taxa, only: [:index, :show]
      get '/taxa/search/:string', to: 'taxa#search'
      resources :protonyms, only: [:index, :show]
      resources :authors, only: [:index, :show]
      resources :author_names, only: [:index, :show]
      resources :names, only: [:index, :show]
      resources :citations, only: [:index, :show]
      resources :taxon_history_items, only: [:index, :show]
      resources :journals, only: [:index, :show]
      resources :publishers, only: [:index, :show]
      resources :references, only: [:index, :show]
      resources :reference_author_names, only: [:index, :show]
      resources :reference_documents, only: [:index, :show]
      resources :reference_sections, only: [:index, :show]
      resources :synonyms, only: [:index, :show]
    end
  end

  resources :antweb_data, only: :index

  resources :feedback, only: [:index, :show, :create, :destroy] do
    collection do
      get :autocomplete
    end
    member do
      put :close
      put :reopen
    end
  end

  resources :comments, only: [:index, :create, :edit, :update]

  # TODO nest more Editor's Panel-ish pages under this (issues, site notices, etc).
  scope path: :panel, controller: :editors_panels do
    root action: :index, as: "editors_panel"
    get :invite_users

    scope module: :editors_panels do
      resources :versions, only: [:index, :show]
      resource :bolton_keys_to_ref_tags, only: [:show, :create]
    end
  end

  get :notifications, to: "notifications#index"

  resources :activities, only: [:index, :destroy]

  resources :site_notices do
    collection do
      post :mark_all_as_read
    end
  end

  resources :taxon_history_items, only: [:index, :show, :edit, :update, :destroy]
  resources :reference_sections, only: [:index, :show, :edit, :update, :destroy]
  resources :synonyms, only: :show

  resources :tooltips do
    scope module: :tooltips do
      resources :history, only: :index
    end
  end

  resources :issues, except: :destroy do
    scope module: :issues do
      resources :history, only: :index
    end
    collection do
      get :autocomplete
    end
    member do
      put :close
      put :reopen
    end
  end

  namespace :markdown do
    post :preview, action: :preview
    get :formatting_help
  end

  resources :database_scripts, only: [:index, :show]

  namespace :my do
    resources :recently_used_references, only: [:index, :create]
  end

  namespace :beta_and_such do
    # Empty for now.
  end

  # Lazy!!
  if Rails.env.development?
    get ':id' => 'beta_and_such#attempt_to_find_record_by_id', constraints: { id: /[0-9|]+/ }
  end

  unless Rails.env.production?
    namespace :widget_tests do
      get :name_field_test
      get :tooltips_test
      get :toggle_dev_css
    end
  end
end

# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'catalog#index'

  mount GrapeSwaggerRails::Engine => '/api_docs'

  resources :authors, only: [:index, :show, :destroy] do
    scope module: :authors do
      collection do
        resource :autocomplete, only: :show
      end
      resource :merges, only: [:new, :show, :create]
    end
    resources :author_names, except: [:index, :show], shallow: true
  end

  namespace :catalog do
    get "random", to: "random#show"
    get "fix_random", to: "fix_random#show"
    resource :search, only: :show
    resource :toggle_display, only: :update
    resource :autocomplete, only: :show
  end
  get 'catalog/:id' => 'catalog#show', as: :catalog
  get 'catalog/:id/bolton' => 'catalog/bolton#show', as: :bolton_catalog_view
  get 'catalog/:id/wikipedia' => 'catalog/wikipedia#show'
  get 'catalog/:id/history' => 'catalog/histories#show', as: :taxon_history
  get 'catalog/:id/hover_preview' => 'catalog/hover_preview#show'
  get 'catalog/:id/what_links_here' => 'catalog/what_links_heres#show', as: :taxon_what_links_here
  get 'catalog/:id/soft_validations' => 'catalog/soft_validations#show', as: :taxon_soft_validations

  get '/documents/:id/:file_name', to: 'references/downloads#show', file_name: /.+/

  resources :institutions do
    scope module: :institutions do
      resource :history, only: :show
    end
  end

  resources :journals, except: [:new, :create] do
    scope module: :journals do
      collection do
        resource :autocomplete, only: :show
      end
    end
  end

  namespace :publishers do
    resource :autocomplete, only: :show
  end

  resources :references do
    scope module: :references do
      collection do
        resource :autocomplete, only: :show
        resource :linkable_autocomplete, only: :show
      end

      resource :history, only: :show
      resource :what_links_here, only: :show

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

  resources :protonyms do
    scope module: :protonyms do
      collection do
        resource :autocomplete, only: :show
      end
      resource :history, only: :show
      resource :what_links_here, only: :show
      resource :soft_validations, only: :show
    end
  end
  namespace :protonyms do
    namespace :localities do
      resource :autocomplete, only: :show
    end
  end

  resources :taxa, except: [:index, :show] do
    resources :taxon_history_items, only: [:new, :create]
    resources :reference_sections, only: [:new, :create]
    scope module: :taxa do
      resource :children, only: [:show]
      resource :create_combination, only: [:new, :show, :create]
      resource :create_combination_help, only: [:new, :show]
      resource :convert_to_subspecies, only: [:new, :create]
      resource :force_parent_change, only: [:show, :create]
      resource :elevate_to_species, only: [:create]
      resource :create_obsolete_combination, only: [:show, :create]
      resource :move_items, only: [:new, :show, :create]
      resource :set_subgenus, only: [:show, :create, :destroy]
      resource :reorder_history_items, only: [:create]
      resource :reorder_reference_sections, only: [:create]
    end
  end

  get 'names/check_name_conflicts' => 'names/check_name_conflicts#show'
  resources :names, only: [:show, :edit, :update] do
    scope module: :names do
      resource :history, only: :show
    end
  end

  devise_for :users, path_prefix: 'my', controllers: { registrations: "my/registrations" }
  resources :users do
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
    end
  end

  resources :antweb_data, only: :index

  resources :feedbacks do
    member do
      put :close
      put :reopen
    end
  end

  resources :comments, only: [:index, :create, :edit, :update]

  scope path: :panel, controller: :editors_panels do
    root action: :index, as: "editors_panel"
    get :invite_users

    scope module: :editors_panels do
      resources :versions, only: [:index, :show]
      resource :bolton_keys_to_ref_tags, only: [:show, :create]
    end
  end

  get :notifications, to: "notifications#index"

  resources :activities, only: [:index, :show, :destroy] do
    collection do
      scope module: :activities do
        resource :unconfirmed, only: :show, as: :unconfirmed_activities
      end
    end
  end

  resources :site_notices do
    collection do
      post :mark_all_as_read
    end
  end

  resources :taxon_history_items, except: [:new, :create] do
    scope module: :taxon_history_items do
      resource :history, only: :show
    end
  end
  resources :reference_sections, except: [:new, :create] do
    scope module: :reference_sections do
      resource :history, only: :show
    end
  end

  resources :tooltips do
    scope module: :tooltips do
      resource :history, only: :show
    end
  end

  resources :issues, except: :destroy do
    scope module: :issues do
      resource :history, only: :show
    end
    member do
      put :close
      put :reopen
    end
  end

  resources :wiki_pages do
    scope module: :wiki_pages do
      collection do
        resource :autocomplete, only: :show
      end
      resource :history, only: :show
    end
  end

  resource :unsubscribe, only: [:show, :create]

  namespace :markdown do
    post :preview, action: :preview
  end

  resources :database_scripts, only: [:index, :show]

  scope :quick_and_dirty_fixes do
    post 'convert_bolton_tags_quick_and_dirty_fix', to: 'quick_and_dirty_fixes#convert_bolton_tags'
    post 'convert_to_taxac_tags_quick_and_dirty_fix', to: 'quick_and_dirty_fixes#convert_to_taxac_tags'
    post 'remove_pages_from_taxac_tags_quick_and_dirty_fix', to: 'quick_and_dirty_fixes#remove_pages_from_taxac_tags'
  end

  namespace :my do
    resource :recently_used_references, only: [:show, :create]
    resource :default_reference, only: :update, controller: :default_reference
  end
end

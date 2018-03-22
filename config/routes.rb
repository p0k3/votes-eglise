Rails.application.routes.draw do

  mount RailsEmailPreview::Engine, at: 'emails'
  devise_for :users, controllers: { invitations: 'users/invitations' }

  authenticated :user do
    namespace :admin do
      resources :users do
        get '/admins/new', to: "admins#new", as: :new_admin
        post '/admins/delete', to: "admins#destroy", as: :admin
      end
      resources :imports
    end

    resources :structures do
      resources :has_memberships, controller: 'structures/has_memberships', except: :create
      resources :campaigns, controller: 'structures/campaigns'
      get '/has_memberships/:member_id/:member_type', to: 'structures/has_memberships#create', as: :add_memberships
      resources :is_memberships, controller: 'structures/is_memberships'
      get '/roles/:resource_id/:resource_type/edit', to: 'structures/roles#edit', as: :edit_structure_resource_roles
      post '/roles/:resource_id/:resource_type/edit', to: 'structures/roles#update', as: :structure_resource_roles
      post '/elector/:resource_id/:resource_type', to: 'structures/electors#update', as: :elector
    end
    resources :imports, to: 'structures/imports', as: :structure_import


    resources :users, only: [:show, :index]
    resources :structures
    resources :campaigns

    post '/voting', to: 'votings#create', as: :voting

    get '/mon-compte', to: "accounts#show", as: :me
    get '/mon-compte/modifier', to: 'accounts#edit', as: :edit_me

    get '/search', to: "search#index", as: :search

    resources :accounts, only: :update

    root :to => redirect('/mon-compte'), as: :authenticated_user

  end
  root to: redirect('/users/sign_in')

end

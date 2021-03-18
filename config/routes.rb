Rails.application.routes.draw do
  root to: 'pages#home'

  get 'help', to: 'pages#help'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations' }
  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  resources :users, only: [] do
    get :blueprints, to: "users#blueprints"

    collection do
      get :blueprints, to: "users#my_blueprints"
      get :collections, to: "users#my_collections"
    end
  end
  resources :blueprints, only: [:index, :new, :show, :edit, :create, :update, :destroy] do
    member do
      put 'like', to: "blueprints#like"
      put 'unlike', to: "blueprints#unlike"
    end
  end
  resources :collections, only: [:new, :show, :index, :edit, :create, :update, :destroy]
end

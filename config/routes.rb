Rails.application.routes.draw do
  get "up", to: "health#show", as: :rails_health_check

  root to: 'pages#home'
  
  devise_for :users
  
  resources :trips do
    resource :preference, only: [:edit, :update], controller: 'trip_preferences'
    resources :expenses, only: [:create, :destroy]
    
    member do
      get :wizard_step_2
      patch :wizard_update_preferences
      post :generate_budget
    end
  end

  resources :cities, only: [:show], param: :slug

  patch "display_currency", to: "display_currency#update", as: :update_display_currency

  # Global Nav items
  get 'ledger', to: 'expenses#index', as: :ledger
  get 'friends', to: 'friends#index', as: :friends
  
  # Sidekiq
  require 'sidekiq/web'
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
end

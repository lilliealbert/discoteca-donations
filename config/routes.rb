Rails.application.routes.draw do
  devise_for :volunteers
  resources :events, only: [:index, :show]
  resources :donors, only: [:index, :show, :edit, :update]
  resources :volunteers, only: [:index, :show]
  resources :donation_requests, only: [:show, :edit, :update]
  resources :donations, only: [:show, :edit, :update]
  resources :bulk_imports, only: [:new, :create]
  resources :templates, only: [:index]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "volunteers#dashboard"
end

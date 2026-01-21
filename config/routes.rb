Rails.application.routes.draw do
  devise_for :volunteers, controllers: { registrations: "volunteers/registrations" }
  resources :events, only: [:index, :show]
  resources :donors, only: [:index, :show, :edit, :update]
  resources :volunteers, only: [:index, :show]
  resources :donation_requests, only: [:show, :new, :create, :edit, :update] do
    collection do
      get :offered
    end
  end
  resources :donations, only: [:show, :edit, :update]
  resources :bulk_imports, only: [:new, :create]
  resources :templates, only: [:index]

  get "offer", to: "public_offers#new", as: :new_public_offer
  post "offer", to: "public_offers#create", as: :public_offers
  get "offer/thank_you", to: "public_offers#thank_you", as: :thank_you_public_offers

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "volunteers#dashboard"
end

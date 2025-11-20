Rails.application.routes.draw do
  devise_for :users

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard
  post "dashboard/generate_forecast", to: "dashboard#generate_forecast", as: :generate_forecast
  post "dashboard/simulate_scenario", to: "dashboard#simulate_scenario", as: :simulate_scenario
  post "dashboard/generate_ai_insights", to: "dashboard#generate_ai_insights", as: :generate_ai_insights

  # Profile management
  resource :profile, only: [:edit, :update]

  # Transactions management
  resources :transactions do
    collection do
      get :upload
      post :import
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  root "home#index"
end

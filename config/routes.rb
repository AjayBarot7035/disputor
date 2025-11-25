Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq Web UI for monitoring background jobs (development only)
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" if Rails.env.development?

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  get "sign_in", to: "sessions#new", as: :new_session
  post "sessions", to: "sessions#create", as: :sessions
  delete "sessions/:id", to: "sessions#destroy", as: :session

  # Webhook routes (no authentication required)
  post "webhooks/disputes", to: "webhooks#disputes", as: :webhooks_disputes

  # Disputes routes
  resources :disputes, only: [:index, :show, :update] do
    resources :evidences, only: [:create]
  end

  # Reports routes
  get "reports/daily_volume", to: "reports#daily_volume", as: :reports_daily_volume
  get "reports/time_to_decision", to: "reports#time_to_decision", as: :reports_time_to_decision

  # Defines the root path route ("/")
  root "disputes#index"
end

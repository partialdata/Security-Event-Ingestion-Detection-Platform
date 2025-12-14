Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :events, only: :create
    end
  end

  namespace :ui do
    resources :alerts, only: %i[index update]
  end

  root "ui/dashboard#index"
end

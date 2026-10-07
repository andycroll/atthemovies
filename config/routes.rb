Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "pages#home"
  resources :films, only: :index
  resources :cinemas, only: :index
  get "films/:id(/:suffix)", to: "films#show", as: :film
  get "cinemas/:cinema_id/performances(/:date)", to: "performances#index", as: :cinema_performances
  get "cinemas/:id(/:suffix)", to: "cinemas#show", as: :cinema

  namespace :operator do
    resources :cinemas, only: [ :edit, :update ]
    resources :films, only: [ :index, :edit, :update ] do
      post :search_tmdb, on: :member
      post :merge, on: :member
    end
  end

  namespace :api do
    get "cinemas", to: "listings#cinemas"
    get "cinemas/:id", to: "listings#cinema"
    get "cinemas/:id/performances", to: "listings#cinema_performances"
    get "films", to: "listings#films"
    get "films/:id", to: "listings#film"
    get "films/:id/performances", to: "listings#film_performances"
    get "films/:id/cinemas", to: "listings#film_cinemas"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

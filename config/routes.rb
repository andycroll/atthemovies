Moviesuk::Application.routes.draw do
  resources :cinemas, only: [:index, :show] do
    resources :screenings, only: [:index]
  end
  resources :films, only: [:index, :show]
end

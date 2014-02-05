Moviesuk::Application.routes.draw do
  resources :cinemas, only: [:index, :show]
  resources :films, only: [:index, :show]
end

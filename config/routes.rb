Moviesuk::Application.routes.draw do
  resources :cinemas, only: [:show]
end

Moviesuk::Application.routes.draw do
  resources :cinemas, only: [:index, :show]
end

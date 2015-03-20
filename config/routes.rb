Atthemovies::Application.routes.draw do
  resources :cinemas, only: [:index, :show] do
    resources :screenings, only: [:index]
  end
  resources :films, only: [:edit, :index, :update] do
    get :triage, on: :collection
    put :merge, on: :member
  end
  resources :films, only: :show

  root 'pages#home'
end

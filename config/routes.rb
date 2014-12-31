Atthemovies::Application.routes.draw do
  resources :cinemas, only: [:index, :show] do
    resources :screenings, only: [:index]
  end
  resources :films, only: [:edit, :index, :show, :update] do
    get :triage, on: :collection
    put :merge, on: :member
  end

  root 'pages#home'
end

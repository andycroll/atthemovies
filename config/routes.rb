Atthemovies::Application.routes.draw do
  scope module: 'api/v1', constraints: APIConstraint.new(version: 1, default: true) do
    resources :cinemas, only: :index
  end

  resources :cinemas, only: [:edit, :index, :show, :update] do
    resources :performances, only: [:index]
  end

  get '/triage' => 'films#triage', as: :triage

  resources :films, only: [:edit, :index, :show, :update] do
    put :merge, on: :member
  end

  root 'pages#home'
end

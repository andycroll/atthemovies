# frozen_string_literal: true
Atthemovies::Application.routes.draw do
  scope module: 'api/v1', constraints: APIConstraint.new(version: 1, default: true) do
    resources :cinemas, only: :index do
      resources :performances, only: :index, controller: 'cinemas/performances'
    end
    resources :films, only: :index do
      resources :performances, only: :index, controller: 'films/performances'
      resources :cinemas, only: :index, controller: 'films/cinemas'
    end
  end

  resources :cinemas, only: [:edit, :index, :show, :update] do
    resources :performances, only: [:index]
  end
  get '/cinemas/:cinema_id/performances/:when' => 'performances#index', as: :dated_cinema_performances

  get '/triage' => 'films#triage', as: :triage

  resources :films, only: [:edit, :index, :show, :update] do
    put :merge, on: :member
  end

  root 'pages#home'
end

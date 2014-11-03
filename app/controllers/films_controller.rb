class FilmsController < ApplicationController
  respond_to :json, :html

  before_filter :http_basic_auth, only: [:edit, :merge, :update]
  before_filter :assign_film, except: :index

  def edit
    @similar_films = Film.similar_to(@film.name) - [@film]
  end

  def index
    @films = Film.whats_on
  end

  def merge
    other_film = Film.find(params[:other_id])
    @film.merge(other_film)
    redirect_to edit_film_path(@film)
  end

  def show
  end

  def update
    @film.add_alternate_name(params[:new_name])
    redirect_to edit_film_path(@film)
  end

  private

  def assign_film
    @film = Film.find(params[:id])
  end
end

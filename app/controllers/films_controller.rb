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
    Films::Merge.enqueue(film_id: @film.id, other_film_id: params[:other_id])
    redirect_to edit_film_path(@film)
  end

  def show
  end

  def update
    if params[:alternate_name]
      @film.add_alternate_name(params[:alternate_name])
    else
      @film.update!(film_attributes)
    end
    redirect_to edit_film_path(@film)
  end

  private

  def assign_film
    @film = Film.find(params[:id])
  end

  def film_attributes
    params.require(:film).permit(:name, :overview, :running_time, :tagline, :tmdb_identifier)
  end
end

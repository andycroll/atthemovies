class FilmsController < ApplicationController
  before_filter :http_basic_auth, only: [:edit, :merge, :update]
  before_filter :assign_film, except: [:index, :triage]

  def edit
    @similar_films = Film.similar_to(@film.name) - [@film]
  end

  def index
    @films = Film.whats_on
  end

  def merge
    Films::Merge.perform_later(@film, Film.find(params[:other_id]))
    redirect_to :back
  end

  def show
  end

  def triage
    @films = Film.no_information.order(:name).page(params[:page])
  end

  def update
    if params[:alternate_name]
      @film.add_alternate_name(params[:alternate_name])
    else
      @film.update_attributes(film_attributes)
    end
    redirect_to :back
  end

  private

  def assign_film
    @film = Film.find(params[:id])
  end

  def film_attributes
    params.require(:film).permit(:information_added, :name, :overview, :running_time, :tagline, :tmdb_identifier)
  end
end

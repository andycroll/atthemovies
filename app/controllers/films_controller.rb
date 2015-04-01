class FilmsController < ApplicationController
  before_filter :http_basic_auth, only: [:edit, :merge, :triage, :update]
  before_filter :assign_film_by_id, except: [:index, :show, :triage]

  def edit
    @similar_films = Film.similar_to(@film.name) - [@film]
  end

  def index
    @films = params[:q] ? Film.similar_to(params[:q]) : Film.whats_on
  end

  def merge
    Films::Merge.perform_now(@film, Film.find(params[:other_id]))
    redirect_to :back
  end

  def show
    @film = Film.find_by_url(params[:id])
  end

  def triage
    @films = if params[:q]
      Film.similar_to(params[:q]).page(params[:page])
    else
      Film.no_information.no_tmdb_id.order('screenings_count DESC').page(params[:page]).per(20)
    end
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

  def assign_film_by_id
    @film = Film.find(params[:id])
  end

  def film_attributes
    params.require(:film).permit(:information_added, :name, :overview, :running_time, :tagline, :tmdb_identifier, :event, :hidden)
  end
end

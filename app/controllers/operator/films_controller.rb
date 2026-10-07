module Operator
  class FilmsController < ApplicationController
    before_action :set_film, except: :index

    def index
      @films = Film.order(:name)
      @films = if params[:q].present?
        @films.where("name LIKE ?", "%#{Film.sanitize_sql_like(params[:q])}%")
      else
        @films.where.not(enrichment_state: [ "matched", "no_match" ])
      end
    end

    def edit
    end

    def update
      @film.transaction do
        @film.update!(params.require(:film).permit(:name, :year, :runtime, :tagline, :overview, :event, :hidden, :enrichment_state, :poster, :backdrop, :poster_source_url, :backdrop_source_url))
        StoreFilmImagesJob.perform_later(@film) if @film.saved_change_to_poster_source_url? || @film.saved_change_to_backdrop_source_url?
        if params[:alternate_name].present?
          @film.film_aliases.create!(name: params[:alternate_name])
        end
        if params[:tmdb_id].present?
          raise ArgumentError, "TMDB ID must be numeric" unless params[:tmdb_id].match?(/\A\d+\z/)
          identifier = @film.external_identifiers.find_or_initialize_by(source: "tmdb_movie")
          identifier.update!(value: params[:tmdb_id])
          @film.update!(enrichment_state: "pending")
          EnrichFilmJob.perform_later(@film)
        end
      end
      redirect_to edit_operator_film_path(@film), notice: "Film saved."
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ArgumentError => error
      flash.now[:alert] = error.message
      render :edit, status: :unprocessable_entity
    end

    def search_tmdb
      SearchTmdbJob.perform_later(@film)
      redirect_to edit_operator_film_path(@film), notice: "TMDB search queued."
    end

    def merge
      target = Film.find_by!(public_id: params[:target_id])
      @film.merge_into!(target)
      redirect_to edit_operator_film_path(target), notice: "Films merged."
    rescue ArgumentError, ActiveRecord::RecordNotUnique => error
      redirect_to edit_operator_film_path(@film), alert: error.message
    end

    private
      def set_film
        @film = Film.find_by!(public_id: params[:id])
      end
  end
end

module Films
  # async collection of TMDB data
  class FetchExternalInformation < ActiveJob::Base
    attr_accessor :film

    def perform(film)
      self.film = film
      return unless film.needs_external_information?

      film.update_external_information_from(tmdb_movie)

      enqueue_fetching_images
    end

    private

    def enqueue_fetching_images
      FetchPoster.perform_later(film)
      FetchBackdrop.perform_later(film)
    end

    def tmdb_movie
      @tmdb_movie ||= ExternalFilm.new(film.tmdb_identifier)
    end
  end
end

module Films
  class Hydrate < ActiveJob::Base
    attr_accessor :film

    def perform(film)
      self.film = film
      return if film.tmdb_identifier.blank?

      film.hydrate(tmdb_movie)
    end

    private

    def tmdb_backdrop_uri
      tmdb_movie.backdrop.uri
    end

    def tmdb_poster_uri
      tmdb_movie.poster.uri
    end

    def tmdb_movie
      @tmdb_movie ||= ExternalFilm.new(film.tmdb_identifier)
    end
  end
end

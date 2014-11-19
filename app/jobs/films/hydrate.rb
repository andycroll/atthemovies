module Films
  class Hydrate < Job
    attr_reader :film_id

    def initialize(args)
      @film_id = args[:film_id]
    end

    def perform
      if tmdb_identifier.present?
        film.hydrate(tmdb_movie)
        film.set_backdrop_source(tmdb_backdrop_uri)
        film.set_poster_source(tmdb_poster_uri)
      end
    end

    private

    def film
      @film ||= Film.find(film_id)
    end

    def tmdb_backdrop_uri
      tmdb_movie.backdrop.uri
    end

    def tmdb_identifier
      film.tmdb_identifier
    end

    def tmdb_poster_uri
      tmdb_movie.poster.uri
    end

    def tmdb_movie
      @tmdb_movie ||= ExternalFilm.new(tmdb_identifier)
    end
  end
end

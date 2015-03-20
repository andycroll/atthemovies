module Films
  class FetchExternalIds < ActiveJob::Base
    attr_accessor :film

    def perform(film)
      self.film = film
      film.update_possibles(possible_ids)
      prime_cache
    end

    private

    def external_films
      @external_films ||= ExternalFilm.find(film.name)
    end

    def possible_ids
      external_films.map(&:tmdb_id)
    end

    def prime_cache
      external_films.each(&:title_and_year)
    end
  end
end

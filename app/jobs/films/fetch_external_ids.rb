module Films
  class FetchExternalIds < ActiveJob::Base
    attr_accessor :film

    def perform(film)
      self.film = film
      film.update_possibles(possible_ids)
      FetchExternalInformation.perform_now(film) if single_film? && titles_match?
      prime_cache
    end

    private

    def external_films
      @external_films ||= ExternalFilm.find(film.name)
    end

    def first_film
      @first_film ||= external_films[0]
    end

    def possible_ids
      external_films.map(&:tmdb_id)
    end

    def prime_cache
      external_films.each(&:title_and_year)
    end

    def single_film?
      external_films.count == 1
    end

    def titles_match?
      film.name == first_film.title
    end
  end
end

module Films
  class FetchExternalIds < ActiveJob::Base
    attr_accessor :film

    def perform(film)
      self.film = film
      film.update_possibles(possible_ids)
      if single_film? && titles_match?
        film.update_attributes(tmdb_identifier: first_film.tmdb_id)
        FetchExternalInformation.perform_now(film)
      end
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
      FilmNameComparison.new(film.name).code == FilmNameComparison.new(first_film.title).code
    end
  end
end

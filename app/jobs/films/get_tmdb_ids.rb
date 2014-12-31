module Films
  class GetTmdbIds < ActiveJob::Base
    attr_accessor :film

    def perform(film)
      self.film = film
      film.update_possibles(possible_tmdb_ids)
    end

    private

    def possible_tmdb_ids
      Tmdb::Movie.find(film.name).map(&:id)
    end
  end
end

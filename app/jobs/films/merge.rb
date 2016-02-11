module Films
  class Merge < ActiveJob::Base
    attr_reader :film, :other_film

    def perform(film, other_film)
      @film       = film
      @other_film = other_film

      migrate_performances
      add_merged_film_name_to_film
      other_film.destroy
    end

    private

    def add_merged_film_name_to_film
      film.add_alternate_name(other_film.name) unless film.name == other_film.name
    end

    def migrate_performances
      other_film_performances.each do |performance|
        film.performances << performance
      end
    end

    def other_film_performances
      @other_film_performances ||= other_film.performances
    end
  end
end

module Films
  class Merge < ActiveJob::Base
    attr_reader :film, :other_film

    def perform(film, other_film)
      @film       = film
      @other_film = other_film

      migrate_screenings
      add_merged_film_name_to_film
      other_film.destroy
    end

    private

    def add_merged_film_name_to_film
      film.add_alternate_name(other_film.name)
    end

    def migrate_screenings
      other_film_screenings.each { |screening| film.screenings << screening }
    end

    def other_film_screenings
      @other_film_screenings ||= other_film.screenings
    end
  end
end

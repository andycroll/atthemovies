module Films
  class Merge < Job
    attr_reader :film_id, :other_film_id

    def initialize(args)
      @film_id       = args[:film_id]
      @other_film_id = args[:other_film_id]
    end

    def perform
      migrate_screenings
      add_merged_film_name_to_film
      other_film.destroy
    end

    private

    def add_merged_film_name_to_film
      film.add_alternate_name(other_film.name)
    end

    def film
      @film ||= Film.find(film_id)
    end

    def migrate_screenings
      other_film_screenings.each { |screening| film.screenings << screening }
    end

    def other_film
      @other_film ||= Film.find(other_film_id)
    end

    def other_film_screenings
      @other_film_screenings ||= other_film.screenings
    end
  end
end

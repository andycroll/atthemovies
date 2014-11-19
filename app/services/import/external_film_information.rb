module Import
  class ExternalFilmInformation
    def perform
      films_with_no_information.each do |film|
        Films::Hydrate.enqueue(film_id: film.id)
      end
    end

    private

    def films_with_no_information
      Film.no_information
    end
  end
end

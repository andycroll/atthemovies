module Import
  class ExternalFilmIds
    def perform
      films_with_no_ids.each do |film|
        Films::GetTmdbIds.enqueue(film_id: film.id)
      end
    end

    private

    def films_with_no_ids
      Film.no_tmdb_details
    end
  end
end

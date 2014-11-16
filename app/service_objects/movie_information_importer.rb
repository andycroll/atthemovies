class MovieInformationImporter
  def get_ids
    films_with_no_ids.each do |film|
      GetTmdbMovieIdsForFilmJob.enqueue(film_id: film.id)
    end
  end

  def hydrate
    films_with_no_information.each do |film|
      Film::HydratorJob.enqueue(film_id: film.id)
    end
  end

  private

  def films_with_no_ids
    Film.no_tmdb_details
  end

  def films_with_no_information
    Film.no_information
  end
end

class MovieInformationImporter
  def get_ids
    films_with_no_info.each do |film|
      GetTmdbMovieIdsForFilmJob.enqueue(film_id: film.id)
    end
  end

  private

  def films_with_no_info
    Film.no_tmdb_details
  end
end

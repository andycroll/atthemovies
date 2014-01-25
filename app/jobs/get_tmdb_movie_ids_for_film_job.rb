class GetTmdbMovieIdsForFilmJob < Job

  attr_reader :film_id

  def initialize(args)
    @film_id = args[:film_id]
  end

  def perform
    film.set_possibles(possible_tmdb_ids)
  end

  private

  def film
    @film ||= Film.find(film_id)
  end

  def possible_tmdb_ids
    Tmdb::Movie.find(film.name).map { |movie| movie.id }
  end
end

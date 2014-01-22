class GetTmdbMovieIdsForFilmJob < Struct.new(:film_id)

  attr_accessor :film

  def perform
    @film = Film.find(film_id)
    film.set_possibles(possible_tmdb_ids)
  end

  private

  def possible_tmdb_ids
    Tmdb::Movie.find(@film.name).map { |movie| movie.id }
  end
end

class FilmHydratorJob < Job

  attr_reader :film_id

  def initialize(args)
    @film_id = args[:film_id]
  end

  def perform
    film.hydrate(tmdb_movie) if tmdb_identifier.present?
  end

  private

  def film
    @film ||= Film.find(film_id)
  end

  def tmdb_identifier
    film.tmdb_identifier
  end

  def tmdb_movie
    @tmdb_movie ||= TmdbMovie.new(tmdb_identifier)
  end
end

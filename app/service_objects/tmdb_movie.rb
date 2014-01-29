class TmdbMovie

  attr_reader :tmdb_id

  def initialize(tmdb_id)
    @tmdb_id = tmdb_id
  end

  # @param name Name of the film
  # @return [Array<TmdbMovie>]
  def self.find(name)
    tmdb_find(name).map { |movie| new(movie.id) }
  end

  # @return <TmdbBackdrop>
  def backdrop
    TmdbBackdrop.new(file_path: tmdb_detail.backdrop_path)
  end

  # @return <String>
  def imdb_number
    tmdb_detail.imdb_id
  end

  # @return <TmdbPoster>
  def poster
    TmdbPoster.new(file_path: tmdb_detail.poster_path)
  end

  private

  def self.tmdb_find(name)
    Tmdb::Movie.find(name)
  end

  def tmdb_detail
    @tmdb_detail ||= Tmdb::Movie.detail(tmdb_id)
  end
end

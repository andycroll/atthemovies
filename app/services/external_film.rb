class ExternalFilm
  attr_reader :tmdb_id

  def initialize(tmdb_id)
    @tmdb_id = tmdb_id
  end

  # @param name Name of the film
  # @return [Array<ExternalFilm>]
  def self.find(name)
    tmdb_find(name).map { |movie| new(movie.id) }
  end

  # @return <ExternalFilm::Backdrop>
  def backdrop
    ExternalFilm::Backdrop.new(file_path: tmdb_detail.backdrop_path)
  end

  # @return <String>
  def imdb_number
    tmdb_detail.imdb_id
  end

  # @return <String>
  def overview
    tmdb_detail.overview
  end

  # @return <ExternalFilm::Poster>
  def poster
    ExternalFilm::Poster.new(file_path: tmdb_detail.poster_path)
  end

  # @return <Integer>
  def runtime
    tmdb_detail.runtime
  end

  # @return <String>
  def tagline
    tmdb_detail.tagline
  end

  # @return <String>
  def title
    tmdb_detail.title
  end

  # @return <String>
  def title_and_year
    Rails.cache.fetch("tmdb_title_and_year_#{tmdb_id}") do
      "#{title} (#{year})"
    end
  end

  # @return <Integer>
  def year
    tmdb_detail.release_date[0..3]
  end

  private

  def self.tmdb_find(name)
    Tmdb::Movie.find(name)
  end

  def tmdb_detail
    @tmdb_detail ||= Tmdb::Movie.detail(tmdb_id)
  end
end

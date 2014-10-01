class Film < ActiveRecord::Base
  has_many :screenings

  validates :name, presence: true

  acts_as_url :name

  scope :whats_on, lambda {
    where('screenings_count > 0').order('screenings_count DESC')
  }

  def hydrate(tmdb_movie)
    update_attributes(imdb_identifier: tmdb_movie.imdb_number.to_s,
                      overview: tmdb_movie.overview,
                      runtime: tmdb_movie.runtime,
                      tagline: tmdb_movie.tagline)
  end

  def set_backdrop_source(uri)
    update_attributes(backdrop_source_uri: uri.to_s)
    store_backdrop
  end

  def set_possibles(array)
    update_attributes(tmdb_possibles: array)
  end

  def set_poster_source(uri)
    update_attributes(poster_source_uri: uri.to_s)
    store_poster
  end

  # use url for routing
  # @return [String]
  def to_param
    "#{id}-#{url}"
  end

  private

  def store_backdrop
    FilmBackdropStorerJob.enqueue(film_id: id)
  end

  def store_poster
    FilmPosterStorerJob.enqueue(film_id: id)
  end
end

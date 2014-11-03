class Film < ActiveRecord::Base
  has_many :screenings
  has_many :cinemas, -> { distinct }, through: :screenings

  validates :name, presence: true

  acts_as_url :name

  scope :similar_to, ->(name) { advanced_search(name: name.tr(' ', '|')) }
  scope :whats_on, lambda {
    where(Film.arel_table[:screenings_count].gt(0))
    .order(screenings_count: :desc)
  }

  def hydrate(tmdb_movie)
    update_attributes(imdb_identifier: tmdb_movie.imdb_number.to_s,
                      overview: tmdb_movie.overview,
                      runtime: tmdb_movie.runtime,
                      tagline: tmdb_movie.tagline)
  end

  def add_alternate_name(name)
    update_attributes(alternate_names: self.alternate_names + [name])
  end

  def merge(other_film)
    other_film.screenings.each { |screening| self.screenings << screening }
    add_alternate_name(other_film.name)
    other_film.destroy
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

class Film < ActiveRecord::Base
  validates :name, presence: true

  def hydrate(tmdb_movie)
    update_attributes( imdb_identifier: tmdb_movie.imdb_number.to_s,
                       overview: tmdb_movie.overview,
                       runtime: tmdb_movie.runtime,
                       tagline: tmdb_movie.tagline)
  end

  def set_possibles(array)
    update_attributes(tmdb_possibles: array)
  end
end

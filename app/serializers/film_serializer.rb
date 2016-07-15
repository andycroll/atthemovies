class FilmSerializer < ActiveModel::Serializer
  attributes :id, :backdrop, :name, :overview, :performances_count, :poster,
             :runtime, :tagline, :tmdb_identifier, :year
end

class FilmSerializer < ActiveModel::Serializer
  attributes :id, :backdrop, :name, :overview, :poster, :runtime, :tagline,
             :tmdb_identifier, :year
end

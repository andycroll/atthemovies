class TmdbCandidate < ApplicationRecord
  belongs_to :film
  validates :tmdb_id, :name, presence: true
end

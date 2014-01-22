class Film < ActiveRecord::Base
  validates :name, presence: true

  def set_possibles(array)
    update_attributes(tmdb_possibles: array)
  end
end

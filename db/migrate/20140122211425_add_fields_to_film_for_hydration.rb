class AddFieldsToFilmForHydration < ActiveRecord::Migration
  def change
    add_column :films, :tmdb_identifier, :integer
    add_column :films, :tmdb_possibles, :string, array: true, default: '{}'
  end
end

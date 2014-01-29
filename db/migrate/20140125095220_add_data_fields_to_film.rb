class AddDataFieldsToFilm < ActiveRecord::Migration
  def change
    add_column :films, :backdrop_file_path, :text
    add_column :films, :poster_file_path, :text

    add_column :films, :imdb_identifier, :string
    add_column :films, :overview, :text

    add_column :films, :runtime, :integer
    add_column :films, :tagline, :text
  end
end

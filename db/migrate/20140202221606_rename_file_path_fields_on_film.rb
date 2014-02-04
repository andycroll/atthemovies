class RenameFilePathFieldsOnFilm < ActiveRecord::Migration
  def change
    rename_column :films, :poster_file_path, :poster_source_uri
    rename_column :films, :backdrop_file_path, :backdrop_source_uri
  end
end

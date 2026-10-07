class AddImageSourcesToFilms < ActiveRecord::Migration[8.1]
  def change
    add_column :films, :poster_source_url, :string
    add_column :films, :backdrop_source_url, :string
  end
end

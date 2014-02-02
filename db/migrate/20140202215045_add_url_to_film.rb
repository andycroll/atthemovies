class AddUrlToFilm < ActiveRecord::Migration
  def change
    add_column :films, :url, :string
  end
end

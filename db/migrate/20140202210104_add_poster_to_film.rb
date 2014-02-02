class AddPosterToFilm < ActiveRecord::Migration
  def change
    add_column :films, :poster, :text
  end
end

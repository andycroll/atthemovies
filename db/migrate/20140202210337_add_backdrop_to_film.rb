class AddBackdropToFilm < ActiveRecord::Migration
  def change
    add_column :films, :backdrop, :text
  end
end

class AddHiddenToFilm < ActiveRecord::Migration
  def change
    add_column :films, :hidden, :boolean, default: false
  end
end
class AddNameHashesToFilm < ActiveRecord::Migration
  def change
    add_column :films, :name_hashes, :text, array: true, default: '{}'
  end
end

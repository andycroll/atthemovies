class AddInformationAddedToFilms < ActiveRecord::Migration
  def change
    add_column :films, :information_added, :boolean, default: false
  end
end

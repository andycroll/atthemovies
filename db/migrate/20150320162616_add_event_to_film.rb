class AddEventToFilm < ActiveRecord::Migration
  def change
    add_column :films, :event, :boolean, default: false
  end
end

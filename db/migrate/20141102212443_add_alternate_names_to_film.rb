class AddAlternateNamesToFilm < ActiveRecord::Migration
  def change
    add_column :films, :alternate_names, :text, array: true, default: []
  end
end

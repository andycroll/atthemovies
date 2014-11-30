class AddYearToFilm < ActiveRecord::Migration
  def change
    add_column :films, :year, :string, limit: 4
  end
end

class AddCounterCacheToFilm < ActiveRecord::Migration
  def change
    add_column :films, :screenings_count, :integer
  end
end

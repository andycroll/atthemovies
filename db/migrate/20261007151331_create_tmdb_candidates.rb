class CreateTmdbCandidates < ActiveRecord::Migration[8.1]
  def change
    create_table :tmdb_candidates do |t|
      t.references :film, null: false, foreign_key: true
      t.string :tmdb_id, null: false
      t.string :name, null: false
      t.integer :year

      t.timestamps
    end
    add_index :tmdb_candidates, [ :film_id, :tmdb_id ], unique: true
  end
end

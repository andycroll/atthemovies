class CreateFilmAliases < ActiveRecord::Migration[8.1]
  def change
    create_table :film_aliases do |t|
      t.references :film, null: false, foreign_key: true
      t.string :name, null: false
      t.string :normalized_name, null: false

      t.timestamps
    end
    add_index :film_aliases, :normalized_name, unique: true
  end
end

class CreatePerformances < ActiveRecord::Migration[8.1]
  def change
    create_table :performances do |t|
      t.references :cinema, null: false, foreign_key: true
      t.references :film, null: false, foreign_key: true
      t.string :dimension, null: false, default: "2d"
      t.string :variant, null: false, default: "standard"
      t.datetime :starting_at, null: false
      t.string :booking_url

      t.timestamps
    end
    add_index :performances, [ :cinema_id, :film_id, :dimension, :starting_at ], unique: true, name: "performance_import_identity"
    add_index :performances, :starting_at
  end
end

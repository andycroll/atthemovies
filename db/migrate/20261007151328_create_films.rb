class CreateFilms < ActiveRecord::Migration[8.1]
  def change
    create_table :films do |t|
      t.string :public_id, null: false
      t.string :name, null: false
      t.integer :year
      t.integer :runtime
      t.string :tagline
      t.text :overview
      t.string :enrichment_state, null: false, default: "pending"
      t.boolean :event, null: false, default: false
      t.boolean :hidden, null: false, default: false
      t.integer :performances_count, null: false, default: 0

      t.timestamps
    end
    add_index :films, :public_id, unique: true
  end
end

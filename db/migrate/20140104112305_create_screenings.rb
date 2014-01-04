class CreateScreenings < ActiveRecord::Migration
  def change
    create_table :screenings do |t|
      t.references :film, null: false
      t.references :cinema, null: false, index: true

      t.string :variant, null: false
      t.datetime :showing_at, null: false

      t.timestamps
    end
  end
end

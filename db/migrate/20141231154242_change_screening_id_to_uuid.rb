class ChangeScreeningIdToUuid < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'

    drop_table :screenings

    create_table :screenings, id: :uuid do |t|
      t.references :film, null: false
      t.references :cinema, null: false, index: true

      t.string :dimension, length: 2, null: false
      t.string :variant, null: false
      t.datetime :showing_at, null: false

      t.timestamps
    end
  end
end

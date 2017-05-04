# frozen_string_literal: true
class ScreeningToPerformance < ActiveRecord::Migration
  def change
    create_table :performances, id: :uuid do |t|
      t.uuid :film_id, null: false
      t.uuid :cinema_id, null: false, index: true

      t.string :dimension, length: 2, null: false
      t.string :variant, null: false
      t.datetime :starting_at, null: false

      t.timestamps
    end

    add_column :films, :performances_count, :integer

    drop_table :screenings do |t|
      t.uuid :film_id, null: false
      t.uuid :cinema_id, null: false, index: true

      t.string :dimension, length: 2, null: false
      t.string :variant, null: false
      t.datetime :showing_at, null: false

      t.timestamps
    end

    remove_column :films, :screenings_count, :integer
  end
end

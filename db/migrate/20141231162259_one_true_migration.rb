# frozen_string_literal: true
class OneTrueMigration < ActiveRecord::Migration[5.2]
  def change
    enable_extension "plpgsql"
    enable_extension 'uuid-ossp'
    enable_extension "pgcrypto"

    create_table :films, id: :uuid do |t|
      t.string :name, null: false, index: true

      t.text :overview
      t.string :year, limit: 4
      t.integer :runtime
      t.text :tagline
      t.text :poster
      t.text :backdrop

      t.integer :tmdb_identifier
      t.string :tmdb_possibles, array: true, default: '{}'
      t.text :backdrop_source_uri
      t.text :poster_source_uri
      t.string :imdb_identifier

      t.string :url
      t.text :alternate_names, array: true, default: '{}'
      t.boolean :information_added, default: false

      t.integer :screenings_count
      t.timestamps
    end

    create_table "cinemas", id: :uuid do |t|
      t.string :name
      t.string :url
      t.decimal :latitude, precision: 9, scale: 6
      t.decimal :longitude, precision: 9, scale: 6
      t.string :street_address
      t.string :extended_address
      t.string :locality
      t.string :postal_code
      t.string :region
      t.string :country
      t.string :country_code, limit: 3
      t.string :brand
      t.string :brand_identifier

      t.timestamps
    end

    add_index :cinemas, [:latitude, :longitude]

    create_table :screenings, id: :uuid do |t|
      t.uuid :film_id, null: false
      t.uuid :cinema_id, null: false, index: true

      t.string :dimension, length: 2, null: false
      t.string :variant, null: false
      t.datetime :showing_at, null: false

      t.timestamps
    end
  end
end

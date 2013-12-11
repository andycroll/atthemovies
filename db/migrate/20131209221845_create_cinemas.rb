class CreateCinemas < ActiveRecord::Migration
  def change
    create_table :cinemas do |t|
      t.string :name
      t.string :url
      t.decimal :latitude, precision: 9, scale: 6
      t.decimal :longitude, precision: 9, scale: 6
      t.string :street_address
      t.string :extended_address
      t.string :locality
      t.string :postal_code
      t.string :region

      t.timestamps
    end
  end
end

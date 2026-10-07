class CreateCinemas < ActiveRecord::Migration[8.1]
  def change
    create_table :cinemas do |t|
      t.string :public_id, null: false
      t.string :name, null: false
      t.string :brand, null: false
      t.string :street_address
      t.string :extended_address
      t.string :locality
      t.string :region
      t.string :postal_code
      t.string :country
      t.string :country_code
      t.decimal :latitude
      t.decimal :longitude
      t.string :screenings_url

      t.timestamps
    end
    add_index :cinemas, :public_id, unique: true
  end
end

class AddGeoIndex < ActiveRecord::Migration
  def change
    add_index :cinemas, [:latitude, :longitude]
  end
end

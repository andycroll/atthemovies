class AddBrandToCinema < ActiveRecord::Migration
  def change
    add_column :cinemas, :brand, :string
  end
end

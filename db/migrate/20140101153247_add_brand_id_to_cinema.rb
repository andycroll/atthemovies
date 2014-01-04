class AddBrandIdToCinema < ActiveRecord::Migration
  def change
    add_column :cinemas, :brand_id, :string
  end
end

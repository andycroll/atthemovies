class AddDimensionToScreening < ActiveRecord::Migration
  def change
    add_column :screenings, :dimension, :string
  end
end

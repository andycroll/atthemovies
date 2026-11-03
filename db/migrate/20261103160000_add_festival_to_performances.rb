class AddFestivalToPerformances < ActiveRecord::Migration[8.1]
  def change
    add_column :performances, :festival, :string
  end
end

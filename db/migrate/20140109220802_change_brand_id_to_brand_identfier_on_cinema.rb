class ChangeBrandIdToBrandIdentfierOnCinema < ActiveRecord::Migration
  def change
    rename_column :cinemas, :brand_id, :brand_identifier
  end
end

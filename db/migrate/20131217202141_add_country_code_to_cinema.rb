class AddCountryCodeToCinema < ActiveRecord::Migration
  def change
    add_column :cinemas, :country, :string
    add_column :cinemas, :country_code, :string, limit: 3
  end
end

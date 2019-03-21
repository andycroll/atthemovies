# frozen_string_literal: true
class ReallyAddUrlsToCinemas < ActiveRecord::Migration[5.2]
  def change
    remove_column :films, :screenings_url
    remove_column :films, :information_url

    add_column :cinemas, :screenings_url, :string
    add_column :cinemas, :information_url, :string
  end
end

# frozen_string_literal: true
class AddUrlsToCinema < ActiveRecord::Migration[5.2]
  def change
    add_column :films, :screenings_url, :string
    add_column :films, :information_url, :string
  end
end

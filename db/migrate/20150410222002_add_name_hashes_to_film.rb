# frozen_string_literal: true
class AddNameHashesToFilm < ActiveRecord::Migration[5.2]
  def change
    add_column :films, :name_hashes, :text, array: true, default: '{}'
  end
end

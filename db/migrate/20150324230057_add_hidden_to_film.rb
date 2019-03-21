# frozen_string_literal: true
class AddHiddenToFilm < ActiveRecord::Migration[5.2]
  def change
    add_column :films, :hidden, :boolean, default: false
  end
end

# frozen_string_literal: true
class AddEventToFilm < ActiveRecord::Migration[5.2]
  def change
    add_column :films, :event, :boolean, default: false
  end
end

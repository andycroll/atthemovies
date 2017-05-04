# frozen_string_literal: true
class AddEventToFilm < ActiveRecord::Migration
  def change
    add_column :films, :event, :boolean, default: false
  end
end

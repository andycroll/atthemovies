class CreateFilms < ActiveRecord::Migration
  def change
    create_table :films do |t|
      t.string :name, null: false, index: true

      t.timestamps
    end
  end
end

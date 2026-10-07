class CreateExternalIdentifiers < ActiveRecord::Migration[8.1]
  def change
    create_table :external_identifiers do |t|
      t.references :identifiable, polymorphic: true, null: false
      t.string :source, null: false
      t.string :value, null: false

      t.timestamps
    end
    add_index :external_identifiers, [ :source, :value ], unique: true
  end
end

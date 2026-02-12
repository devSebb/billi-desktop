class CreateTripPreferenceItems < ActiveRecord::Migration[7.2]
  def change
    create_table :trip_preference_items, id: :uuid do |t|
      t.references :trip_preference, null: false, foreign_key: true, type: :uuid
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :category, null: false
      t.decimal :value, precision: 10, scale: 2
      t.string :unit

      t.timestamps
    end

    add_index :trip_preference_items, [:trip_id, :category]
  end
end

class CreateTripPreferences < ActiveRecord::Migration[7.2]
  def change
    create_table :trip_preferences, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :lodging_style, default: "mixed"
      t.integer :hotel_nights, default: 0
      t.integer :airbnb_nights, default: 0
      t.integer :fancy_restaurant_meals, default: 0
      t.integer :casual_restaurant_meals, default: 0
      t.integer :street_food_meals, default: 0
      t.integer :activities_count, default: 0
      t.integer :nightlife_nights, default: 0
      t.string :shopping_budget_level, default: "medium"
      t.string :overall_comfort_level, default: "balanced"
      t.text :notes

      t.timestamps
    end
  end
end

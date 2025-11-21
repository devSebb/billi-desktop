class CreateTripBudgets < ActiveRecord::Migration[7.2]
  def change
    create_table :trip_budgets, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.decimal :total_trip_cost, precision: 10, scale: 2
      t.decimal :per_person_cost, precision: 10, scale: 2
      t.decimal :lodging_total, precision: 10, scale: 2
      t.decimal :restaurants_total, precision: 10, scale: 2
      t.decimal :activities_total, precision: 10, scale: 2
      t.decimal :drinks_total, precision: 10, scale: 2
      t.decimal :shopping_total, precision: 10, scale: 2
      t.decimal :other_total, precision: 10, scale: 2
      t.string :currency, default: "USD"

      t.timestamps
    end
  end
end

class CreateTripBudgetItems < ActiveRecord::Migration[7.2]
  def change
    create_table :trip_budget_items, id: :uuid do |t|
      t.references :trip_budget, null: false, foreign_key: true, type: :uuid
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :category, null: false
      t.decimal :amount, precision: 10, scale: 2, default: 0.0
      t.string :currency, default: "USD"

      t.timestamps
    end

    add_index :trip_budget_items, [:trip_id, :category]
  end
end

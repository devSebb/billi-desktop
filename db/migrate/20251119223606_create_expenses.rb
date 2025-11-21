class CreateExpenses < ActiveRecord::Migration[7.2]
  def change
    create_table :expenses, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :category
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency, default: "USD"
      t.date :spent_at
      t.string :description

      t.timestamps
    end
  end
end

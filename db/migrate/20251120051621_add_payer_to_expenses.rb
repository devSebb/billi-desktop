class AddPayerToExpenses < ActiveRecord::Migration[7.2]
  def change
    add_reference :expenses, :payer, null: true, foreign_key: { to_table: :trip_participants }, type: :uuid
  end
end

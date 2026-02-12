class CleanupLegacyColumns < ActiveRecord::Migration[7.2]
  def change
    # 2. Remove old expenses.payer_id
    # Using remove_reference which removes column + index + foreign_key safely
    # We assume backfill has been run.
    
    remove_reference :expenses, :payer, foreign_key: { to_table: :trip_participants } if column_exists?(:expenses, :payer_id)

    # Note: We are NOT removing columns from trip_budgets or trip_preferences yet as per 
    # "Keep trip_budgets for now" and "Keep table for now" instructions, 
    # but if we wanted to remove the columns:
    
    # change_table :trip_budgets do |t|
    #   t.remove :lodging_total, :restaurants_total, :activities_total, ...
    # end
    
    # For now, we only strictly remove the payer_id as it was part of the explicit replacement flow.
  end
end

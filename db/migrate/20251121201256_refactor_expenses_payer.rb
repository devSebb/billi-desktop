class RefactorExpensesPayer < ActiveRecord::Migration[7.2]
  def change
    # Add new column
    add_reference :expenses, :payer_participant, foreign_key: { to_table: :trip_participants }, type: :uuid, index: true

    # Old column `payer_id` will be removed in a later migration after backfill.
    # Note: `payer_id` currently exists and has a foreign key to trip_participants in schema.rb, 
    # but we are renaming/refactoring to be explicit.
  end
end

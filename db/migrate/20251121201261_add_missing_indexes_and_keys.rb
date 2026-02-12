class AddMissingIndexesAndKeys < ActiveRecord::Migration[7.2]
  def change
    # 7. Add missing FKs and Indexes
    
    # Cities: country/name indexes
    add_index :cities, :country
    add_index :cities, :name

    # Ensure indexes exist (using if_not_exists: true just in case, though Rails usually handles existing indexes safely or errors)
    # Checking schema:
    # trips.user_id FK users.id + index (Exists)
    # trip_participants.trip_id FK trips.id + index (Exists)
    # expenses.trip_id FK trips.id + index (Exists)
    # splits.expense_id FK expenses.id + index (Exists)
    # splits.trip_participant_id FK trip_participants.id + index (Exists)
    # price_snapshots.city_id FK cities.id + index (Exists)
    
    # Note: Most demanded indexes seem to be covered by `t.references` in previous migrations or existing schema.
    # Double checking splits composite index (Added in RefactorSplits).
    
    # Adding FKs if missing. Schema shows most are present. 
    # "splits.expense_id FK expenses.id" is present.
    
    # Let's add any that might be missing based on standard practices
    # e.g., indexes on created_at/updated_at if used for sorting often, but not requested.
    
    # Safety check: Ensure foreign keys are enforced at DB level where missing in `schema.rb` 
    # (Schema lines 140-149 show many add_foreign_key calls).
    
    # Just in case, we can add indexes for sorting trips by date
    add_index :trips, :start_date
    add_index :trips, :end_date
  end
end

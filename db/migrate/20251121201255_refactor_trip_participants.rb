class RefactorTripParticipants < ActiveRecord::Migration[7.2]
  def change
    # 1. Ensure user_id is nullable (it is by default, but explicit change_column_null ensures it)
    change_column_null :trip_participants, :user_id, true

    # 2. Add Check Constraint: (user_id IS NOT NULL) OR (name IS NOT NULL)
    # We use a raw SQL check constraint for Postgres.
    add_check_constraint :trip_participants, 
                         "(user_id IS NOT NULL) OR (name IS NOT NULL)", 
                         name: "check_trip_participants_user_or_name"

    # 3. Add unique index for (trip_id, user_id) ensuring a user joins a trip only once
    add_index :trip_participants, [:trip_id, :user_id], unique: true, where: "user_id IS NOT NULL"
  end
end

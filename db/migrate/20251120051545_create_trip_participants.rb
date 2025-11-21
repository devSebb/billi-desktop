class CreateTripParticipants < ActiveRecord::Migration[7.2]
  def change
    create_table :trip_participants, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.references :user, null: true, foreign_key: true, type: :uuid
      t.string :name
      t.string :email
      t.boolean :is_user

      t.timestamps
    end
  end
end

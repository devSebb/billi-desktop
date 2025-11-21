class CreateTrips < ActiveRecord::Migration[7.2]
  def change
    create_table :trips, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :destination_city
      t.string :destination_country
      t.date :start_date
      t.date :end_date
      t.integer :travelers_count
      t.string :currency, default: "USD"
      t.string :status, default: "draft"

      t.timestamps
    end
  end
end

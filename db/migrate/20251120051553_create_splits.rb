class CreateSplits < ActiveRecord::Migration[7.2]
  def change
    create_table :splits, id: :uuid do |t|
      t.references :expense, null: false, foreign_key: true, type: :uuid
      t.references :trip_participant, null: false, foreign_key: true, type: :uuid
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end

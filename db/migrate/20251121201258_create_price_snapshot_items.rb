class CreatePriceSnapshotItems < ActiveRecord::Migration[7.2]
  def change
    create_table :price_snapshot_items, id: :uuid do |t|
      t.references :price_snapshot, null: false, foreign_key: true, type: :uuid
      t.references :city, null: false, foreign_key: true, type: :uuid # Denormalized for convenience
      t.string :category, null: false
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency, default: "USD"
      t.string :source
      t.datetime :collected_at

      t.timestamps
    end

    add_index :price_snapshot_items, [:city_id, :category, :collected_at], name: 'index_price_items_on_city_cat_collected'
  end
end

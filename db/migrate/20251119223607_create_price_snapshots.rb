class CreatePriceSnapshots < ActiveRecord::Migration[7.2]
  def change
    create_table :price_snapshots, id: :uuid do |t|
      t.string :city
      t.string :country
      t.integer :month
      t.string :season
      t.string :category
      t.decimal :average_amount, precision: 10, scale: 2
      t.string :currency, default: "USD"

      t.timestamps
    end

    add_index :price_snapshots, [:city, :country, :month, :category], name: 'index_price_snapshots_on_loc_month_cat'
  end
end

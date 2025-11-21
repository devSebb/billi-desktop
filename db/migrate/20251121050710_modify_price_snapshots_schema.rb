class ModifyPriceSnapshotsSchema < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up { execute "DELETE FROM price_snapshots" }
    end

    # Remove old columns
    remove_index :price_snapshots, name: 'index_price_snapshots_on_loc_month_cat'
    remove_column :price_snapshots, :city, :string
    remove_column :price_snapshots, :country, :string
    remove_column :price_snapshots, :month, :integer
    remove_column :price_snapshots, :season, :string
    remove_column :price_snapshots, :category, :string
    remove_column :price_snapshots, :average_amount, :decimal

    # Add new columns
    # We assume cities table uses UUIDs
    add_reference :price_snapshots, :city, null: false, foreign_key: true, type: :uuid
    add_column :price_snapshots, :source, :string
    add_column :price_snapshots, :data, :jsonb, default: {}
    add_column :price_snapshots, :collected_at, :datetime

    # Index for fast lookup of latest snapshot
    add_index :price_snapshots, [:city_id, :collected_at]
    add_index :price_snapshots, :source
    add_index :price_snapshots, :data, using: :gin
  end
end

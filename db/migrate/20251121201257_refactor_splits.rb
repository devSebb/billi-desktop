class RefactorSplits < ActiveRecord::Migration[7.2]
  def change
    # Add split_type enum and weight
    create_enum :split_type_enum, ["fixed", "equal", "percentage"]

    add_column :splits, :split_type, :enum, enum_type: "split_type_enum", default: "fixed", null: false
    add_column :splits, :weight, :decimal, precision: 10, scale: 2

    # Add composite index
    add_index :splits, [:expense_id, :trip_participant_id]
  end
end

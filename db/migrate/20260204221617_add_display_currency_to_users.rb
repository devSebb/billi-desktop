class AddDisplayCurrencyToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :display_currency, :string, default: "USD", null: false
  end
end

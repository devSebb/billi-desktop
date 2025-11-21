class CreateCities < ActiveRecord::Migration[7.2]
  def change
    create_table :cities, id: :uuid do |t|
      t.string :name
      t.string :country
      t.string :slug

      t.timestamps
    end
    add_index :cities, :slug
  end
end

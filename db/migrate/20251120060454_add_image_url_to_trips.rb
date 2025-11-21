class AddImageUrlToTrips < ActiveRecord::Migration[7.2]
  def change
    add_column :trips, :image_url, :string
  end
end

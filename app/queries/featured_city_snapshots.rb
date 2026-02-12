# Returns one "display" snapshot per city: prefer latest source=traveltables, else latest estimated.
# Same selection as CitySnapshotPicker. Includes :city, :items to avoid N+1.
class FeaturedCitySnapshots
  def self.call(limit: 10)
    # DISTINCT ON (city_id): for each city, keep first row after ordering by priority then collected_at
    latest_snapshot_ids = PriceSnapshot
      .select("DISTINCT ON (city_id) id")
      .order(
        Arel.sql("city_id, CASE WHEN source = 'traveltables' THEN 0 WHEN source = 'estimated' THEN 1 ELSE 2 END, collected_at DESC")
      )

    PriceSnapshot
      .where(id: latest_snapshot_ids)
      .includes(:city, :items)
      .order(collected_at: :desc)
      .limit(limit)
  end
end










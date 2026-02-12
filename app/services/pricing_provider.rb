module PricingProvider
  ESTIMATED_SNAPSHOT_WINDOW_DAYS = 30

  def self.for(city:, country:, start_date:, end_date:)
    # Try Snapshot first (real or estimated)
    prices = Snapshot.new(
      city: city,
      country: country,
      start_date: start_date,
      end_date: end_date
    ).prices

    return prices if prices

    # No snapshot for this city: ensure estimated snapshot exists (idempotent, 30-day window)
    city_record = City.find_by(name: city, country: country) || City.find_by(name: city)
    if city_record
      ensure_estimated_snapshot(city_record)
      prices = Snapshot.new(
        city: city,
        country: country,
        start_date: start_date,
        end_date: end_date
      ).prices
      return prices if prices
    end

    # Fallback to Static (Legacy) when city not in DB or snapshot creation failed
    Static.new(city: city, country: country, start_date: start_date, end_date: end_date).prices
  end

  def self.ensure_estimated_snapshot(city)
    return if city.price_snapshots.where(source: "estimated").where("collected_at > ?", ESTIMATED_SNAPSHOT_WINDOW_DAYS.days.ago).exists?

    CostOfLiving::GenerateMockSnapshot.call(city)
  end
end

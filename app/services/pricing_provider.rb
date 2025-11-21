module PricingProvider
  def self.for(city:, country:, start_date:, end_date:)
    # Try Snapshot first
    prices = Snapshot.new(
      city: city, 
      country: country, 
      start_date: start_date, 
      end_date: end_date
    ).prices

    return prices if prices

    # Fallback to Static (Legacy)
    # This ensures old behavior if API data is missing
    Static.new(city: city, country: country, start_date: start_date, end_date: end_date).prices
  end
end

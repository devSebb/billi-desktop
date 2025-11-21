module PricingProvider
  def self.for(city:, country:, start_date:, end_date:)
    # Default to Static for MVP. Could switch based on config.
    Static.new(city: city, country: country, start_date: start_date, end_date: end_date).prices
  end
end


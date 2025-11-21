module CostOfLiving
  class UpdateCitySnapshot
    def self.call(city)
      new(city).call
    end

    def initialize(city)
      @city = city
      @client = TravelTablesClient.new
    end

    def call
      json = @client.fetch_city_costs(@city.name, @city.country)
      return unless json

      data = NormalizeTravelTables.call(json)
      return if data.empty?

      # Use currency from API or default
      currency = json["currency"] || "USD" 

      @city.price_snapshots.create!(
        source: "traveltables",
        currency: currency,
        data: data,
        collected_at: Time.current
      )
    end
  end
end


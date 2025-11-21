module PricingProvider
  class Static
    def initialize(city:, country:, start_date:, end_date:)
      # Interface compatibility
    end

    def prices
      # LEGACY FALLBACK:
      # Since we moved to live API data stored in jsonb, the old PriceSnapshot rows are gone.
      # This fallback provides safe defaults if the API data hasn't been loaded for a city yet.
      default_prices
    end

    private

    def default_prices
      {
        "lodging_budget" => 50,
        "lodging_midrange" => 120,
        "lodging_premium" => 300,
        "restaurant_cheap" => 15,
        "restaurant_midrange" => 40,
        "restaurant_fancy" => 100,
        "street_food" => 5,
        "activity_standard" => 20,
        "activity_touristy" => 50,
        "drinks" => 10,
        "shopping" => 100,
        "other" => 50
      }
    end
  end
end

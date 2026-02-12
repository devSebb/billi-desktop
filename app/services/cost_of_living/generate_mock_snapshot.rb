module CostOfLiving
  # Generates an estimated PriceSnapshot with keys matching PricingProvider::Snapshot expectations.
  # Use when no real API snapshot exists for a city. Source is "estimated" for UI labeling.
  class GenerateMockSnapshot
    # Keys that PricingProvider::Snapshot reads from snapshot.data
    SNAPSHOT_KEYS = %w[
      stay_rent_1br_center_month
      stay_rent_1br_outside_month
      food_cheap_meal
      food_mid_meal
      drinks_beer
      coffee
    ].freeze

    def self.call(city)
      new(city).call
    end

    def initialize(city)
      @city = city
    end

    def call
      # Deterministic values per city so estimates are reproducible
      base = (@city.name.length * 5) + 10

      data = {
        "stay_rent_1br_center_month" => (base * 45).round(2),
        "stay_rent_1br_outside_month" => (base * 35).round(2),
        "food_cheap_meal" => (base * 1.2).round(2),
        "food_mid_meal" => (base * 4.0).round(2),
        "drinks_beer" => (base * 0.5).round(2),
        "coffee" => (base * 0.3).round(2)
      }

      @city.price_snapshots.create!(
        source: "estimated",
        currency: "USD",
        data: data,
        collected_at: Time.current
      )
    end
  end
end

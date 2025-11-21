module CostOfLiving
  class NormalizeTravelTables
    MAPPING = {
      "Meal, Inexpensive Restaurant" => "food_cheap_meal",
      "Meal for 2 People, Mid-range Restaurant, Three-course" => "food_mid_meal",
      "Domestic Beer (0.5 liter draught)" => "drinks_beer",
      "Cappuccino (regular)" => "coffee",
      "Apartment (1 bedroom) in City Centre" => "stay_rent_1br_center_month",
      "Apartment (1 bedroom) Outside of Centre" => "stay_rent_1br_outside_month",
      "One-way Ticket (Local Transport)" => "transport_public_single",
      "Monthly Pass (Regular Price)" => "transport_public_monthly",
      "Taxi 1km (Normal Tariff)" => "transport_taxi_per_km"
    }.freeze

    def self.call(api_response)
      new(api_response).call
    end

    def initialize(api_response)
      @prices = api_response["prices"] || []
    end

    def call
      data = {}
      
      # Build lookup for O(1) access
      price_map = @prices.each_with_object({}) do |item, hash|
        hash[item["item_name"]] = item
      end

      MAPPING.each do |api_name, internal_key|
        item = price_map[api_name]
        next unless item

        # Prefer average_price
        val = item["average_price"] || item["avg_price"] || item["price"]
        
        if val
          val = val.to_f
          
          # Special handling: Meal for 2 -> per person
          if api_name == "Meal for 2 People, Mid-range Restaurant, Three-course"
             val = val / 2.0
          end
          
          data[internal_key] = val
        end
      end
      
      data
    end
  end
end


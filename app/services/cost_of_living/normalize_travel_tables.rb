module CostOfLiving
  class NormalizeTravelTables
    # Map API item_name (or close variant) -> internal key. API uses "avg" for value and varying item_name wording.
    MAPPING = {
      "Meal, Inexpensive Restaurant" => "food_cheap_meal",
      "Meal in Inexpensive Restaurant" => "food_cheap_meal",
      "Meal for 2 People, Mid-range Restaurant, Three-course" => "food_mid_meal",
      "Domestic Beer (0.5 liter draught)" => "drinks_beer",
      "Domestic Beer, 0.5 liter Draught" => "drinks_beer",
      "Cappuccino (regular)" => "coffee",
      "Cappuccino" => "coffee",
      "Apartment (1 bedroom) in City Centre" => "stay_rent_1br_center_month",
      "One bedroom apartment in city centre" => "stay_rent_1br_center_month",
      "Apartment (1 bedroom) Outside of Centre" => "stay_rent_1br_outside_month",
      "One bedroom apartment outside of city centre" => "stay_rent_1br_outside_month",
      "One-way Ticket (Local Transport)" => "transport_public_single",
      "One-way Ticket, Local Transport" => "transport_public_single",
      "Monthly Pass (Regular Price)" => "transport_public_monthly",
      "Monthly Pass, Regular Price" => "transport_public_monthly",
      "Taxi 1km (Normal Tariff)" => "transport_taxi_per_km",
      "Taxi, price for 1 km, Normal Tariff" => "transport_taxi_per_km"
    }.freeze

    def self.call(api_response)
      new(api_response).call
    end

    def initialize(api_response)
      # Goal A: Ensure @prices is always set
      if api_response.present?
        @prices = api_response["prices"] || api_response.dig("data", "prices") || []
      else
        @prices = []
      end
    end

    def call
      return {} if @prices.blank?

      data = {}
      
      # Goal B: Normalized/Fuzzy Matching
      # Build lookup map with normalized keys for O(1) access where possible
      price_map = @prices.each_with_object({}) do |item, hash|
        next unless item["item_name"]
        norm_name = normalize_string(item["item_name"])
        hash[norm_name] = item
      end

      MAPPING.each do |api_name, internal_key|
        target_key = normalize_string(api_name)
        
        # 1. Try exact normalized match
        item = price_map[target_key]

        # 2. Fallback to include? match (e.g. "Domestic Beer" matching "Domestic Beer (0.5 liter)")
        unless item
          # Find any key in map that contains target or is contained by target
          match_key = price_map.keys.find { |k| k.include?(target_key) || target_key.include?(k) }
          item = price_map[match_key] if match_key
        end

        unless item
          # Debug log for missing keys
          Rails.logger.debug { "[NormalizeTravelTables] Missing mapping for: '#{api_name}' (normalized: '#{target_key}')" }
          next
        end

        # API returns avg / min / max; also support average_price, avg_price, price
        val = item["average_price"] || item["avg_price"] || item["price"] || item["avg"]
        
        if val
          val = val.to_f
          
          # Special handling: Meal for 2 -> per person
          # We check the original api_name from MAPPING to determine if logic applies
          if api_name == "Meal for 2 People, Mid-range Restaurant, Three-course"
             val = val / 2.0
          end
          
          data[internal_key] = val
        end
      end
      
      data
    end

    private

    def normalize_string(str)
      # Downcase, remove punctuation, strip, collapse whitespace
      str.to_s.downcase.gsub(/[[:punct:]]/, '').squish
    end
  end
end

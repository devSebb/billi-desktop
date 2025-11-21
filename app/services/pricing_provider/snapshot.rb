module PricingProvider
  class Snapshot
    def initialize(city:, country:, start_date:, end_date:)
      @city_name = city
      @country_name = country
      @start_date = start_date
      @end_date = end_date
    end

    def prices
      city = City.find_by(name: @city_name)
      # Try to match country if possible, but City name is primary key in our seeds.
      
      snapshot = city&.price_snapshots&.recent&.first
      
      return nil unless snapshot
      
      data = snapshot.data
      
      # Derivation Logic
      
      # Rents are monthly. Convert to nightly.
      rent_center = (data["stay_rent_1br_center_month"] || 0).to_f
      rent_outside = (data["stay_rent_1br_outside_month"] || 0).to_f
      
      # Heuristics for Hotels vs Airbnbs
      # Hotel is significantly more expensive than long-term rent pro-rated.
      hotel_night = (rent_center / 30.0) * 3.0
      airbnb_night = (rent_outside / 30.0) * 1.8 
      
      # Food
      cheap_meal = (data["food_cheap_meal"] || 0).to_f
      mid_meal = (data["food_mid_meal"] || 0).to_f
      
      # Drinks
      beer = (data["drinks_beer"] || 0).to_f
      coffee = (data["coffee"] || 0).to_f
      
      # Activities / Shopping (derived from meal index usually)
      # Activity is often ~1-2x a mid-range meal
      activity_base = mid_meal > 0 ? mid_meal : 15.0
      
      {
        "lodging_budget" => airbnb_night * 0.6,
        "lodging_midrange" => hotel_night,
        "lodging_premium" => hotel_night * 3.0,
        
        "restaurant_cheap" => cheap_meal,
        "restaurant_midrange" => mid_meal,
        "restaurant_fancy" => mid_meal * 2.5,
        "street_food" => cheap_meal * 0.6,
        
        "activity_standard" => activity_base,
        "activity_touristy" => activity_base * 3.0,
        
        "drinks" => beer > 0 ? beer : 5.0,
        "shopping" => activity_base * 2.0,
        "other" => 10.0 # Buffer
      }
    end
  end
end


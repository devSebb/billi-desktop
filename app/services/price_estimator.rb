# Legacy; BudgetGenerator uses PricingProvider (Snapshot/Static). Kept for reference or fallback.
class PriceEstimator
  # This is a simplified mock of a pricing engine.
  # In a real app, this would query a database of average prices per city/season.
  
  BASE_RATES = {
    "Paris" => { hotel: 250, airbnb: 180, meal_fancy: 80, meal_casual: 30, activity: 50 },
    "Tokyo" => { hotel: 200, airbnb: 150, meal_fancy: 60, meal_casual: 20, activity: 40 },
    "New York" => { hotel: 350, airbnb: 250, meal_fancy: 100, meal_casual: 40, activity: 70 },
    "Bali" => { hotel: 100, airbnb: 80, meal_fancy: 40, meal_casual: 15, activity: 30 },
    "London" => { hotel: 300, airbnb: 220, meal_fancy: 90, meal_casual: 35, activity: 60 },
    "Berlin" => { hotel: 180, airbnb: 130, meal_fancy: 60, meal_casual: 25, activity: 40 },
    "Mexico City" => { hotel: 120, airbnb: 90, meal_fancy: 50, meal_casual: 20, activity: 30 },
    "Barcelona" => { hotel: 200, airbnb: 160, meal_fancy: 70, meal_casual: 30, activity: 45 },
    "default" => { hotel: 150, airbnb: 120, meal_fancy: 60, meal_casual: 25, activity: 40 }
  }

  SEASONAL_MULTIPLIERS = {
    1 => 0.8, 2 => 0.8, 3 => 0.9, 4 => 1.0, 5 => 1.1, 6 => 1.2, 
    7 => 1.3, 8 => 1.3, 9 => 1.1, 10 => 1.0, 11 => 0.9, 12 => 1.2
  }

  def initialize(trip)
    @trip = trip
    @pref = trip.trip_preference
    @rates = BASE_RATES[@trip.destination_city] || BASE_RATES["default"]
    @multiplier = SEASONAL_MULTIPLIERS[@trip.start_date.month] || 1.0
  end

  def call
    calculate_budget
  end

  private

  def calculate_budget
    nights = @trip.duration_nights
    travelers = @trip.travelers_count
    
    # Lodging
    hotel_cost = @pref.hotel_nights * @rates[:hotel] * @multiplier
    airbnb_cost = @pref.airbnb_nights * @rates[:airbnb] * @multiplier
    # Assume lodging cost is PER ROOM/UNIT. If multiple travelers, maybe we split?
    # Prompt says "per person and per trip". Usually hotel price is per room.
    # Let's assume 2 people per room for simplicity, or just treating it as total cost for the group if we consider "trip cost".
    # However, the "per person" budget is key. 
    # Let's assume the rates are "per person equivalent" for simplicity in this mock, 
    # OR calculate total and divide.
    # Let's treat rates as "per room" and assume 1 room for every 2 travelers (ceil).
    rooms_needed = (travelers / 2.0).ceil
    total_lodging = (hotel_cost + airbnb_cost) * rooms_needed
    
    # Food
    # Assume 2 meals a day: 1 lunch (casual), 1 dinner (mix). Plus breakfast (cheap/included).
    # Let's use the fancy/casual/street counts from preferences if available, or estimates.
    # Preferences has: fancy_restaurant_meals, casual_restaurant_meals, street_food_meals (integers).
    # These are likely "per person" counts.
    total_food_per_person = 
      (@pref.fancy_restaurant_meals * @rates[:meal_fancy]) +
      (@pref.casual_restaurant_meals * @rates[:meal_casual]) +
      (@pref.street_food_meals * (@rates[:meal_casual] * 0.5))
    
    # Fill in remaining meals with casual if counts are low
    meals_accounted = @pref.fancy_restaurant_meals + @pref.casual_restaurant_meals + @pref.street_food_meals
    total_meals_needed = nights * 2
    if meals_accounted < total_meals_needed
      remaining = total_meals_needed - meals_accounted
      total_food_per_person += remaining * @rates[:meal_casual]
    end
    
    total_food = total_food_per_person * travelers * @multiplier

    # Activities
    total_activities_per_person = @pref.activities_count * @rates[:activity]
    total_activities = total_activities_per_person * travelers * @multiplier

    # Drinks/Nightlife
    # nightlife_nights * cost per night out
    cost_per_night_out = 60 # global avg
    total_drinks_per_person = @pref.nightlife_nights * cost_per_night_out
    total_drinks = total_drinks_per_person * travelers * @multiplier

    # Shopping
    shopping_map = { "low" => 50, "medium" => 200, "high" => 500, "luxury" => 1500 }
    shopping_per_person = shopping_map[@pref.shopping_budget_level] || 200
    total_shopping = shopping_per_person * travelers

    # Other / Transport (local)
    # simple daily rate
    daily_transport = 15
    total_other = daily_transport * nights * travelers

    grand_total = total_lodging + total_food + total_activities + total_drinks + total_shopping + total_other
    per_person = grand_total / travelers

    # Update or create TripBudget
    budget = @trip.trip_budget || @trip.build_trip_budget
    budget.update(
      total_trip_cost: grand_total,
      per_person_cost: per_person,
      lodging_total: total_lodging,
      restaurants_total: total_food,
      activities_total: total_activities,
      drinks_total: total_drinks,
      shopping_total: total_shopping,
      other_total: total_other
    )
    
    budget
  end
end


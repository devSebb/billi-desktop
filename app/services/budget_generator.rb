class BudgetGenerator
  def initialize(trip)
    @trip = trip
    @pref = trip.trip_preference
  end

  def call
    return unless @pref

    prices = PricingProvider.for(
      city: @trip.destination_city,
      country: @trip.destination_country,
      start_date: @trip.start_date,
      end_date: @trip.end_date
    )

    # Determine price tier based on comfort level
    lodging_tier = case @pref.overall_comfort_level
                   when "backpacker" then "lodging_budget"
                   when "luxury" then "lodging_premium"
                   else "lodging_midrange"
                   end

    # Calculate Lodging (Total for the group)
    # Assumption: Prices are per-person per-night equivalent
    total_nights = (@trip.end_date - @trip.start_date).to_i
    hotel_cost = (@pref.hotel_nights || 0) * prices[lodging_tier].to_f * @trip.travelers_count
    airbnb_cost = (@pref.airbnb_nights || 0) * prices[lodging_tier].to_f * @trip.travelers_count
    lodging_total = hotel_cost + airbnb_cost

    # Calculate Food
    food_total = (
      (@pref.fancy_restaurant_meals || 0) * prices["restaurant_fancy"].to_f +
      (@pref.casual_restaurant_meals || 0) * prices["restaurant_midrange"].to_f +
      (@pref.street_food_meals || 0) * prices["street_food"].to_f
    ) * @trip.travelers_count

    # Calculate Activities
    # Assumption: 'activities_count' is total activities per person
    activities_total = (@pref.activities_count || 0) * prices["activity_standard"].to_f * @trip.travelers_count

    # Nightlife / Drinks
    # Assumption: nightlife_nights * avg spend (say 3 drinks)
    drinks_total = (@pref.nightlife_nights || 0) * 3 * prices["drinks"].to_f * @trip.travelers_count

    # Shopping
    shopping_multiplier = case @pref.shopping_budget_level
                          when "low" then 0.5
                          when "high" then 3.0
                          else 1.0
                          end
    shopping_total = prices["shopping"].to_f * shopping_multiplier * @trip.travelers_count

    # Other / Buffer (daily per person)
    other_total = total_nights * prices["other"].to_f * @trip.travelers_count

    # Total
    grand_total = lodging_total + food_total + activities_total + drinks_total + shopping_total + other_total
    per_person = grand_total / @trip.travelers_count

    # Update or Create Budget
    budget = @trip.trip_budget || @trip.build_trip_budget
    budget.update!(
      total_trip_cost: grand_total,
      per_person_cost: per_person,
      lodging_total: lodging_total,
      restaurants_total: food_total,
      activities_total: activities_total,
      drinks_total: drinks_total,
      shopping_total: shopping_total,
      other_total: other_total,
      currency: "USD" # MVP fixed
    )
  end
end


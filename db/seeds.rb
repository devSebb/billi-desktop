# Clear old data
Expense.destroy_all
TripBudget.destroy_all
TripPreference.destroy_all
Trip.destroy_all
User.destroy_all
PriceSnapshot.destroy_all

puts "Creating Users..."
user = User.create!(
  email: "demo@billi.app",
  password: "password",
  password_confirmation: "password"
)

puts "Creating Price Snapshots..."
cities = [
  { city: "Rio de Janeiro", country: "Brazil", currency: "USD" },
  { city: "Buenos Aires", country: "Argentina", currency: "USD" },
  { city: "Tokyo", country: "Japan", currency: "USD" },
  { city: "Paris", country: "France", currency: "USD" }
]

months = (1..12).to_a
categories = [
  "lodging_budget", "lodging_midrange", "lodging_premium",
  "restaurant_cheap", "restaurant_midrange", "restaurant_fancy", "street_food",
  "activity_standard", "activity_touristy",
  "drinks", "shopping", "other"
]

# Base prices for Rio (approx)
base_prices = {
  "lodging_budget" => 25, "lodging_midrange" => 80, "lodging_premium" => 250,
  "restaurant_cheap" => 8, "restaurant_midrange" => 25, "restaurant_fancy" => 60, "street_food" => 4,
  "activity_standard" => 15, "activity_touristy" => 40,
  "drinks" => 5, "shopping" => 100, "other" => 20
}

cities.each do |loc|
  multiplier = case loc[:city]
               when "Buenos Aires" then 0.8
               when "Tokyo" then 1.5
               when "Paris" then 1.8
               else 1.0
               end

  months.each do |month|
    # Seasonal variance (high season in Dec-Feb for South America, Jun-Aug for Europe/Japan)
    is_high_season = if ["Brazil", "Argentina"].include?(loc[:country])
                       [12, 1, 2].include?(month)
                     else
                       [6, 7, 8].include?(month)
                     end
    
    season_mult = is_high_season ? 1.3 : 1.0

    categories.each do |cat|
      amount = base_prices[cat] * multiplier * season_mult
      # Add some randomness
      amount = amount * rand(0.9..1.1)
      
      PriceSnapshot.create!(
        city: loc[:city],
        country: loc[:country],
        month: month,
        season: is_high_season ? "high" : "low",
        category: cat,
        average_amount: amount.round(2),
        currency: "USD"
      )
    end
  end
end

puts "Creating Sample Trip..."
trip = Trip.create!(
  user: user,
  name: "New Year in Rio",
  destination_city: "Rio de Janeiro",
  destination_country: "Brazil",
  start_date: Date.today + 30,
  end_date: Date.today + 37,
  travelers_count: 2,
  currency: "USD",
  status: "planned"
)

pref = trip.create_trip_preference!(
  lodging_style: "hotel_only",
  hotel_nights: 7,
  airbnb_nights: 0,
  fancy_restaurant_meals: 2,
  casual_restaurant_meals: 10,
  street_food_meals: 5,
  activities_count: 4,
  nightlife_nights: 3,
  shopping_budget_level: "medium",
  overall_comfort_level: "balanced",
  notes: "Excited for the beach!"
)

# Generate Budget
BudgetGenerator.new(trip).call

# Add some expenses
trip.expenses.create!(category: "lodging", amount: 200.00, spent_at: Date.today, description: "Hotel Deposit")
trip.expenses.create!(category: "activities", amount: 50.00, spent_at: Date.today, description: "Sugarloaf Tickets")

puts "Done! User: demo@billi.app / password"

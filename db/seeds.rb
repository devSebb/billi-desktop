# Clear old data
Expense.destroy_all
TripBudget.destroy_all
TripPreference.destroy_all
Trip.destroy_all
PriceSnapshot.destroy_all
City.destroy_all
User.destroy_all

puts "Creating Users..."
user = User.create!(
  email: "demo@billi.app",
  password: "password",
  password_confirmation: "password"
)

puts "Creating Cities..."
cities_data = [
  ["London", "United Kingdom"],
  ["Bangkok", "Thailand"],
  ["Paris", "France"],
  ["Dubai", "United Arab Emirates"],
  ["New York City", "United States"],
  ["Hong Kong", "China SAR"],
  ["Singapore", "Singapore"],
  ["Rome", "Italy"],
  ["Tokyo", "Japan"],
  ["Istanbul", "Turkey"],
  ["Barcelona", "Spain"],
  ["Venice", "Italy"],
  ["Amsterdam", "Netherlands"],
  ["Seoul", "South Korea"],
  ["Kuala Lumpur", "Malaysia"],
  ["Antalya", "Turkey"],
  ["Miami", "United States"],
  ["Los Angeles", "United States"],
  ["Prague", "Czech Republic"],
  ["Mecca", "Saudi Arabia"],
  ["Osaka", "Japan"],
  ["Madrid", "Spain"],
  ["Cairo", "Egypt"],
  ["Berlin", "Germany"],
  ["Vienna", "Austria"],
  ["Florence", "Italy"],
  ["Cancun", "Mexico"],
  ["Dubrovnik", "Croatia"],
  ["Lisbon", "Portugal"],
  ["Bali (Denpasar)", "Indonesia"],
  ["Marrakech", "Morocco"],
  ["Rio de Janeiro", "Brazil"],
  ["Sydney", "Australia"],
  ["Montreal", "Canada"],
  ["Athens", "Greece"],
  ["Shanghai", "China"],
  ["Cape Town", "South Africa"],
  ["Budapest", "Hungary"],
  ["Moscow", "Russia"],
  ["St. Petersburg", "Russia"],
  ["Edinburgh", "United Kingdom"],
  ["Hanoi", "Vietnam"],
  ["Brussels", "Belgium"],
  ["Stockholm", "Sweden"],
  ["Jaipur", "India"],
  ["Kyoto", "Japan"],
  ["Salzburg", "Austria"],
  ["Havana", "Cuba"],
  ["Doha", "Qatar"],
  ["San Francisco", "United States"]
]

cities_data.each do |name, country|
  City.create!(
    name: name,
    country: country,
    slug: name.parameterize
  )
end

puts "Creating Sample Trip..."
city = City.find_by(name: "Rio de Janeiro")
# Fallback if Rio is not in the list (it is)
city ||= City.first 

trip = Trip.create!(
  user: user,
  name: "New Year in #{city.name}",
  destination_city: city.name,
  destination_country: city.country,
  start_date: Date.today + 30,
  end_date: Date.today + 37,
  travelers_count: 2,
  currency: "USD",
  status: "planned"
)

trip.create_trip_preference!(
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
  notes: "Excited!"
)

# Note: Budget generation will fail or produce zero until snapshots are loaded.
# BudgetGenerator.new(trip).call

puts "Done! User: demo@billi.app / password"

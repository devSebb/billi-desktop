# Safe to run in production: only creates city records if missing.
# Does NOT wipe users, trips, or any other data.
namespace :db do
  desc "Seed cities only (safe for production). Creates the app's 50 cities if they don't exist."
  task seed_cities: :environment do
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

    created = 0
    cities_data.each do |name, country|
      next if City.exists?(name: name, country: country)
      City.create!(name: name, country: country, slug: name.parameterize)
      created += 1
    end

    puts "Cities: #{created} created, #{City.count} total."
  end
end

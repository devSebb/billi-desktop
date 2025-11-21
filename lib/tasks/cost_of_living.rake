namespace :cost_of_living do
  desc "Preload initial snapshots for supported cities (max 10 per run)"
  task preload_initial_snapshots: :environment do
    puts "Starting preload check..."

    # Find cities with 0 snapshots
    # We use left_outer_joins to find cities without snapshots efficiently
    cities_needed = City.where.missing(:price_snapshots).limit(10)

    if cities_needed.empty?
      puts "All supported cities already have an initial snapshot; nothing to preload."
      next
    end

    puts "Found #{cities_needed.count} cities needing initialization (fetching max 10)..."

    cities_needed.each do |city|
      puts "Fetching for #{city.name}, #{city.country}..."
      begin
        CostOfLiving::UpdateCitySnapshot.call(city)
        puts "  -> Success."
      rescue => e
        puts "  -> Failed: #{e.message}"
      end
      
      sleep 1
    end

    puts "Done. Run again in 1 hour if more cities remain."
  end
end


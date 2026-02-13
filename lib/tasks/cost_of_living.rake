namespace :cost_of_living do
  desc "Preload initial snapshots for cities with no data (max 10 per run, rate-limit friendly)"
  task preload_initial_snapshots: :environment do
    api_key = ENV["RAPIDAPI_COST_LIVING_KEY"] || Rails.application.credentials.dig(:rapidapi, :cost_living_key)

    puts "--- Cost of Living: Preload initial snapshots ---"
    puts ""

    unless api_key.present?
      puts "ERROR: API key missing."
      puts "Set RAPIDAPI_COST_LIVING_KEY in .env or add rapidapi.cost_living_key to Rails credentials."
      exit 1
    end
    puts "API key: present"
    puts ""

    # Only cities with zero snapshots; minimal columns; cap at 10 to respect rate limits
    cities = City
      .select(:id, :name, :country)
      .where.missing(:price_snapshots)
      .limit(10)
      .to_a

    if cities.empty?
      puts "No cities need preloading (all have at least one snapshot)."
      puts "Done."
      exit 0
    end

    puts "Cities with no snapshot yet: #{cities.size} (max 10 per run)"
    cities.each_with_index { |c, i| puts "  #{i + 1}. #{c.name}, #{c.country}" }
    puts ""

    succeeded = []
    failed = {}

    cities.each_with_index do |city, index|
      n = index + 1
      total = cities.size
      print "[#{n}/#{total}] #{city.name}, #{city.country} ... "
      $stdout.flush

      begin
        CostOfLiving::UpdateCitySnapshot.call(city)
        puts "OK"
        succeeded << "#{city.name}, #{city.country}"
      rescue CostOfLiving::RateLimitError => e
        puts "RATE LIMITED"
        puts ""
        puts "*** Stopping: API rate limit (429) hit. ***"
        puts e.message
        puts "Only 1 city was attempted this run. Run again later (e.g. in 1 hour) to fetch more."
        puts "On RapidAPI free tier you may have very few requests per hour/month."
        exit 1
      rescue => e
        puts "FAILED"
        failed["#{city.name}, #{city.country}"] = e.message
      end

      sleep 1 if n < total
    end

    puts ""
    puts "--- Summary ---"
    puts "Succeeded: #{succeeded.size}"
    succeeded.each { |s| puts "  + #{s}" }
    if failed.any?
      puts "Failed: #{failed.size}"
      failed.each { |city, msg| puts "  - #{city}: #{msg}" }
    end
    puts ""
    puts "Done. Run again later to preload more cities (rate limit: run periodically)."
  end

  desc "Refresh snapshots from API (latest data). All cities by default; set LIMIT=N to cap. Use for prod to (re)fetch current prices."
  task refresh_snapshots: :environment do
    api_key = ENV["RAPIDAPI_COST_LIVING_KEY"] || Rails.application.credentials.dig(:rapidapi, :cost_living_key)

    puts "--- Cost of Living: Refresh snapshots (latest data) ---"
    puts ""

    unless api_key.present?
      puts "ERROR: API key missing."
      puts "Set RAPIDAPI_COST_LIVING_KEY in .env or add rapidapi.cost_living_key to Rails credentials."
      exit 1
    end
    puts "API key: present"
    puts ""

    limit = ENV["LIMIT"]&.to_i
    limit = 10 if limit.nil? || limit < 1

    cities = City.select(:id, :name, :country).limit(limit).to_a

    if cities.empty?
      puts "No cities in database. Run db:seed first."
      exit 0
    end

    puts "Refreshing up to #{cities.size} cities (LIMIT=#{limit})"
    cities.each_with_index { |c, i| puts "  #{i + 1}. #{c.name}, #{c.country}" }
    puts ""

    succeeded = []
    failed = {}

    cities.each_with_index do |city, index|
      n = index + 1
      total = cities.size
      print "[#{n}/#{total}] #{city.name}, #{city.country} ... "
      $stdout.flush

      begin
        CostOfLiving::UpdateCitySnapshot.call(city)
        puts "OK"
        succeeded << "#{city.name}, #{city.country}"
      rescue CostOfLiving::RateLimitError => e
        puts "RATE LIMITED"
        puts ""
        puts "*** Stopping: API rate limit (429) hit. ***"
        puts e.message
        puts "Run again later (e.g. LIMIT=5) to refresh more."
        exit 1
      rescue => e
        puts "FAILED"
        failed["#{city.name}, #{city.country}"] = e.message
      end

      sleep 1 if n < total
    end

    puts ""
    puts "--- Summary ---"
    puts "Succeeded: #{succeeded.size}"
    succeeded.each { |s| puts "  + #{s}" }
    if failed.any?
      puts "Failed: #{failed.size}"
      failed.each { |city, msg| puts "  - #{city}: #{msg}" }
    end
    puts ""
    puts "Done. To refresh more cities, run again (or set LIMIT=20 etc.)."
  end
end

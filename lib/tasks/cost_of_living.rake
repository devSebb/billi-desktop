# Round-robin helper: next N records after cursor (by created_at), wrapping to start when past the end.
def cities_after_cursor(scope, cursor_value, limit)
  scope = scope.select(:id, :name, :country, :created_at).order(:created_at)
  if cursor_value.present?
    last_at = cursor_value.is_a?(String) ? Time.zone.parse(cursor_value) : cursor_value
    next_batch = scope.where("created_at > ?", last_at).limit(limit).to_a
    return next_batch if next_batch.any?
  end
  scope.limit(limit).to_a
end

namespace :cost_of_living do
  CURSOR_CACHE_KEY = "cost_of_living/refresh_cursor"
  CURSOR_CACHE_EXPIRY = 10.years  # round-robin cursor; don't expire

  desc "Preload initial snapshots for cities with no data (max 10 per run, rate-limit friendly). Round-robins so each run continues from last; wraps to start after the last city."
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

    cursor = Rails.cache.read(CURSOR_CACHE_KEY)
    scope = City.where.missing(:price_snapshots)
    cities = cities_after_cursor(scope, cursor, 10)

    if cities.empty?
      puts "No cities need preloading (all have at least one snapshot)."
      puts "Done."
      exit 0
    end

    puts "Cities with no snapshot yet: #{cities.size} (max 10 per run, round-robin from cursor)"
    cities.each_with_index { |c, i| puts "  #{i + 1}. #{c.name}, #{c.country}" }
    puts ""

    succeeded = []
    failed = {}
    last_cursor = cursor

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
        Rails.cache.write(CURSOR_CACHE_KEY, city.created_at.iso8601, expires_in: CURSOR_CACHE_EXPIRY)
        puts ""
        puts "*** Stopping: API rate limit (429) hit. ***"
        puts e.message
        puts "Cursor advanced; next run will continue from the next city. Run again later (e.g. in 1 hour)."
        exit 1
      rescue => e
        puts "FAILED"
        failed["#{city.name}, #{city.country}"] = e.message
      end
      last_cursor = city.created_at
      sleep 1 if n < total
    end

    if last_cursor
      Rails.cache.write(CURSOR_CACHE_KEY, last_cursor.iso8601, expires_in: CURSOR_CACHE_EXPIRY)
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
    puts "Done. Run again later to preload more cities (round-robin; next run continues from where this left off)."
  end

  desc "Refresh snapshots from API (latest data). Round-robins: continues from last-refreshed city, wraps to start after the last. Set LIMIT=N to cap per run."
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

    cursor = Rails.cache.read(CURSOR_CACHE_KEY)
    cities = cities_after_cursor(City.all, cursor, limit)

    if cities.empty?
      puts "No cities in database. Run db:seed_cities first."
      exit 0
    end

    puts "Refreshing up to #{cities.size} cities (LIMIT=#{limit}, round-robin from cursor)"
    cities.each_with_index { |c, i| puts "  #{i + 1}. #{c.name}, #{c.country}" }
    puts ""

    succeeded = []
    failed = {}
    last_cursor = nil

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
        Rails.cache.write(CURSOR_CACHE_KEY, city.created_at.iso8601, expires_in: CURSOR_CACHE_EXPIRY)
        puts ""
        puts "*** Stopping: API rate limit (429) hit. ***"
        puts e.message
        puts "Cursor advanced; next run will continue from the next city. Run again later."
        exit 1
      rescue => e
        puts "FAILED"
        failed["#{city.name}, #{city.country}"] = e.message
      end
      last_cursor = city.created_at
      sleep 1 if n < total
    end

    if last_cursor
      Rails.cache.write(CURSOR_CACHE_KEY, last_cursor.iso8601, expires_in: CURSOR_CACHE_EXPIRY)
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
    puts "Done. Next run continues from the next city (wraps after last)."
  end
end

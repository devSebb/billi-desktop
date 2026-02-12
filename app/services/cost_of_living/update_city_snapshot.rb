module CostOfLiving
  class UpdateCitySnapshot
    def self.call(city)
      new(city).call
    end

    def initialize(city)
      @city = city
      @client = TravelTablesClient.new
    end

    def call
      # Goal E: Ensure associations used exist
      # If PriceSnapshot doesn't already have:
      # has_many :items, class_name: "PriceSnapshotItem", dependent: :destroy
      # (Note: This is handled in the model, verified by user instructions)

      # Goal D: Caching + Rate-limit friendly behavior
      json = if should_cache?
               Rails.cache.fetch(cache_key, expires_in: 12.hours) do
                 fetch_data
               end
             else
               fetch_data
             end
      
      raise "API returned nil (Rate Limit or Error)" unless json

      data = NormalizeTravelTables.call(json)
      
      if data.empty?
        # Log the first ~20 item_name values from the API to help mapping
        raw_items = (json["prices"] || json.dig("data", "prices") || []).first(20).map { |i| i["item_name"] }
        Rails.logger.info "[COL] Empty normalization for #{@city.name}. Raw items sample: #{raw_items}"
        
        raise "Normalized data is empty"
      end

      # Use currency from API, or first price's currency_code, or default
      prices = json["prices"] || json.dig("data", "prices") || []
      currency = json["currency"].presence || prices.dig(0, "currency_code").presence || "USD" 

      snapshot = @city.price_snapshots.create!(
        source: "traveltables",
        currency: currency,
        data: data,
        collected_at: Time.current
      )

      # Align with new schema: Create individual items
      data.each do |category, amount|
        snapshot.items.create!(
          city: @city,
          category: category,
          amount: amount,
          currency: currency,
          source: "traveltables",
          collected_at: snapshot.collected_at
        )
      end
    end

    private

    def fetch_data
      @client.fetch_city_costs(@city.name, @city.country)
    rescue RateLimitError => e
      # Log clear message including retry_after
      Rails.logger.error("[COL] Rate Limit Hit for #{@city.name}. Retry after: #{e.retry_after}s. Message: #{e.message}")
      # Re-raise so rake task can stop
      raise e
    end

    def should_cache?
      Rails.env.development? || Rails.env.test?
    end

    def cache_key
      "traveltables_raw:#{@city.id}"
    end
  end
end

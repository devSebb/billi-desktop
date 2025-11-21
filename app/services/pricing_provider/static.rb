module PricingProvider
  class Static
    def initialize(city:, country:, start_date:, end_date:)
      @city = city
      @country = country
      @start_date = start_date
      @end_date = end_date
    end

    def prices
      # Identify months involved
      months = (@start_date..@end_date).map(&:month).uniq
      
      # Fetch snapshots
      snapshots = PriceSnapshot.for_location(@city, @country).where(month: months)
      
      return default_prices if snapshots.empty?

      # Average across the months found
      grouped = snapshots.group_by(&:category)
      
      result = grouped.transform_values do |records|
        records.sum(&:average_amount) / records.size
      end
      
      default_prices.merge(result)
    end

    private

    def default_prices
      {
        "lodging_budget" => 50,
        "lodging_midrange" => 120,
        "lodging_premium" => 300,
        "restaurant_cheap" => 15,
        "restaurant_midrange" => 40,
        "restaurant_fancy" => 100,
        "street_food" => 5,
        "activity_standard" => 20,
        "activity_touristy" => 50,
        "drinks" => 10,
        "shopping" => 100,
        "other" => 50
      }
    end
  end
end


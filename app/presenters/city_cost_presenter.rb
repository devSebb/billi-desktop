# Returns a stable, ordered list of cost rows for the UI. Resolves value from snapshot.items
# then snapshot.data so we can label value_source (:item or :data) and snapshot.source.
# Canonical categories match NormalizeTravelTables internal keys; easy to extend.
class CityCostPresenter
  CATEGORIES = [
    [:food_cheap_meal, "Meal, inexpensive"],
    [:food_mid_meal, "Meal, mid-range (per person)"],
    [:drinks_beer, "Beer (0.5L draught)"],
    [:coffee, "Cappuccino"],
    [:stay_rent_1br_center_month, "Rent 1BR, city centre (month)"],
    [:stay_rent_1br_outside_month, "Rent 1BR, outside centre (month)"],
    [:transport_public_single, "One-way local transport"],
    [:transport_public_monthly, "Monthly transport pass"],
    [:transport_taxi_per_km, "Taxi per km"]
  ].freeze

  # Keys to show on the card (4–6 scan-friendly). Full list on profile.
  CARD_KEYS = %w[
    food_mid_meal coffee transport_public_single stay_rent_1br_center_month drinks_beer transport_taxi_per_km
  ].freeze

  def self.call(snapshot)
    new(snapshot).call
  end

  def self.rows_for_card(snapshot)
    return [] unless snapshot

    full = new(snapshot).call
    keys = CARD_KEYS
    full.select { |row| keys.include?(row[:key].to_s) && row[:present?] }.first(6)
  end

  def initialize(snapshot)
    @snapshot = snapshot
  end

  def call
    return [] unless @snapshot

    items_by_category = @snapshot.items.index_by(&:category)
    data = @snapshot.data || {}
    currency = @snapshot.currency.presence || "USD"

    CATEGORIES.map do |key, label|
      key_s = key.to_s
      item = items_by_category[key_s]
      from_data = data[key_s]

      if item&.amount.present?
        { key: key, label: label, amount: item.amount, currency: currency, value_source: :item, present?: true }
      elsif from_data.present?
        { key: key, label: label, amount: from_data.to_d, currency: currency, value_source: :data, present?: true }
      else
        { key: key, label: label, amount: nil, currency: currency, value_source: nil, present?: false }
      end
    end
  end
end

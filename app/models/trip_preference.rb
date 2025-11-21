class TripPreference < ApplicationRecord
  belongs_to :trip

  enum :lodging_style, { mixed: "mixed", hotel_only: "hotel_only", airbnb_only: "airbnb_only" }, suffix: true
  enum :shopping_budget_level, { low: "low", medium: "medium", high: "high" }, suffix: true
  enum :overall_comfort_level, { backpacker: "backpacker", balanced: "balanced", luxury: "luxury" }, suffix: true
end

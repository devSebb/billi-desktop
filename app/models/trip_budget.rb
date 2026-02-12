class TripBudget < ApplicationRecord
  belongs_to :trip
  has_many :trip_budget_items, dependent: :destroy
  
  # Helper to get total from items
  def calculated_total_trip_cost
    trip_budget_items.sum(:amount)
  end

  def calculated_total_by_category(cat)
    trip_budget_items.where(category: cat).sum(:amount)
  end
end

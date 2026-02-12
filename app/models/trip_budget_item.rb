class TripBudgetItem < ApplicationRecord
  belongs_to :trip_budget
  belongs_to :trip

  validates :category, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end


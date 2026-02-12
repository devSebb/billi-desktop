class Split < ApplicationRecord
  belongs_to :expense
  belongs_to :trip_participant
  
  enum :split_type, { fixed: "fixed", equal: "equal", percentage: "percentage" }, default: "fixed"
  
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end

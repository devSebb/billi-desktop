class PriceSnapshotItem < ApplicationRecord
  belongs_to :price_snapshot
  belongs_to :city

  validates :category, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end


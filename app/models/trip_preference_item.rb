class TripPreferenceItem < ApplicationRecord
  belongs_to :trip_preference
  belongs_to :trip

  validates :category, presence: true
  validates :value, numericality: true
end


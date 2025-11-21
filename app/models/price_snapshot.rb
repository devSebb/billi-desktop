class PriceSnapshot < ApplicationRecord
  validates :city, :country, :month, :category, :average_amount, presence: true
  
  # Scopes for easy lookup
  scope :for_location, ->(city, country) { where('LOWER(city) = ? AND LOWER(country) = ?', city.downcase, country.downcase) }
  scope :for_month, ->(month) { where(month: month) }
end

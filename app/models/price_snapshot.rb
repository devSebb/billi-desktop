class PriceSnapshot < ApplicationRecord
  belongs_to :city

  validates :source, presence: true
  validates :data, presence: true
  validates :collected_at, presence: true
  
  scope :recent, -> { order(collected_at: :desc) }
end

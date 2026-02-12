class PriceSnapshot < ApplicationRecord
  belongs_to :city
  has_many :items, class_name: 'PriceSnapshotItem', dependent: :destroy

  validates :source, presence: true
  validates :collected_at, presence: true
  
  scope :recent, -> { order(collected_at: :desc) }
end

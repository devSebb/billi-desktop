class City < ApplicationRecord
  has_many :price_snapshots, dependent: :destroy

  validates :name, presence: true
  validates :country, presence: true
  validates :slug, presence: true, uniqueness: true
end

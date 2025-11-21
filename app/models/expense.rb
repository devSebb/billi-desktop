class Expense < ApplicationRecord
  belongs_to :trip
  belongs_to :payer, class_name: 'TripParticipant', optional: true
  has_many :splits, dependent: :destroy
  
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true
  validates :date, presence: true # Mapped to spent_at in schema usually, need to check schema.
  
  alias_attribute :date, :spent_at
  
  CATEGORIES = %w[accommodation food activities transport shopping drinks misc].freeze
end

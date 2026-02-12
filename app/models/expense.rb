class Expense < ApplicationRecord
  belongs_to :trip
  belongs_to :payer_participant, class_name: 'TripParticipant', optional: true
  
  # Backward compatibility alias (if needed during transition)
  alias_attribute :payer_id, :payer_participant_id
  
  has_many :splits, dependent: :destroy
  
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true
  validates :date, presence: true
  
  alias_attribute :date, :spent_at
  
  CATEGORIES = %w[accommodation food activities transport shopping drinks misc].freeze

  def payer_user
    payer_participant&.user
  end
end

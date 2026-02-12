class TripParticipant < ApplicationRecord
  belongs_to :trip
  belongs_to :user, optional: true
  
  # New association name matching the foreign key on Expense
  has_many :paid_expenses, class_name: 'Expense', foreign_key: 'payer_participant_id', dependent: :nullify
  has_many :splits, dependent: :destroy
  
  # Validation: Name is required only if not linked to a user
  validates :name, presence: true, unless: -> { user_id.present? }
  
  # Ensure unique user per trip (db constraint also exists)
  validates :user_id, uniqueness: { scope: :trip_id, allow_nil: true }
end

class TripParticipant < ApplicationRecord
  belongs_to :trip
  belongs_to :user, optional: true
  
  has_many :paid_expenses, class_name: 'Expense', foreign_key: 'payer_id', dependent: :nullify
  has_many :splits, dependent: :destroy
  
  validates :name, presence: true
end

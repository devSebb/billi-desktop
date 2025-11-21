class FriendsController < ApplicationController
  before_action :authenticate_user!

  def index
    @trips = current_user.trips.order(start_date: :desc)
    
    if params[:trip_id].present?
      @selected_trip = @trips.find_by(id: params[:trip_id])
    else
      @selected_trip = @trips.first
    end

    if @selected_trip
      @participants = @selected_trip.trip_participants
      @expenses = @selected_trip.expenses
      calculate_balances
      calculate_settlements
    end
  end

  private

  def calculate_balances
    # Simple equal split logic for MVP: Everyone splits everything equally
    total_spent = @expenses.sum(:amount)
    participant_count = @participants.count
    
    return if participant_count == 0

    share_per_person = total_spent / participant_count
    
    @balances = []
    
    @participants.each do |participant|
      paid = @expenses.where(payer_id: participant.id).sum(:amount)
      balance = paid - share_per_person
      
      @balances << {
        participant: participant,
        paid: paid,
        share: share_per_person,
        balance: balance
      }
    end
    
    @balances.sort_by! { |b| -b[:balance] }
  end

  def calculate_settlements
    return unless @balances
    
    # Deep copy to not mutate display balances
    working_balances = @balances.map { |b| b.dup }
    @settlements = []

    # Greedy algorithm
    while working_balances.any? { |b| b[:balance].abs > 0.01 }
      # Sort by balance descending
      working_balances.sort_by! { |b| -b[:balance] }
      
      creditor = working_balances.first
      debtor = working_balances.last
      
      break if creditor[:balance] < 0.01 || debtor[:balance] > -0.01

      amount = [creditor[:balance], debtor[:balance].abs].min
      
      @settlements << {
        from: debtor[:participant].name,
        to: creditor[:participant].name,
        amount: amount
      }
      
      creditor[:balance] -= amount
      debtor[:balance] += amount
    end
  end
end


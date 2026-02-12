class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    @trips = current_user.trips.order(start_date: :desc)
    
    if params[:trip_id].present?
      @selected_trip = @trips.find_by(id: params[:trip_id])
    else
      @selected_trip = @trips.first
    end

    @expenses = @selected_trip ? @selected_trip.expenses.order(spent_at: :desc) : []
  end

  def create
    @trip = current_user.trips.find(params[:trip_id])
    @expense = @trip.expenses.build(expense_params)
    
    if @expense.save
      redirect_to trip_path(@trip), notice: "Expense logged."
    else
      redirect_to trip_path(@trip), alert: "Could not save expense."
    end
  end

  def destroy
    @trip = current_user.trips.find(params[:trip_id])
    @expense = @trip.expenses.find(params[:id])
    @expense.destroy
    redirect_to trip_path(@trip), notice: "Expense removed."
  end

  private

  def expense_params
    params.require(:expense).permit(:category, :amount, :spent_at, :description, :payer_participant_id)
  end
end


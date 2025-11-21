class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:show, :edit, :update, :destroy, :wizard_step_2, :wizard_update_preferences, :generate_budget]

  def index
    @trips = current_user.trips.order(created_at: :desc)
  end

  def show
    @budget = @trip.trip_budget
    @preference = @trip.trip_preference
    @expenses = @trip.expenses.order(spent_at: :desc)
    @expense = Expense.new
  end

  def new
    @trip = current_user.trips.build
  end

  def create
    @trip = current_user.trips.build(trip_params)
    if @trip.save
      @trip.create_trip_preference!
      redirect_to wizard_step_2_trip_path(@trip)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      if @trip.trip_budget.present?
        BudgetGenerator.new(@trip).call
      end
      redirect_to trip_path(@trip), notice: "Trip updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def wizard_step_2
    @preference = @trip.trip_preference
  end

  def wizard_update_preferences
    @preference = @trip.trip_preference
    if @preference.update(preference_params)
      BudgetGenerator.new(@trip).call
      redirect_to trip_path(@trip), notice: "Trip budget generated!"
    else
      render :wizard_step_2, status: :unprocessable_entity
    end
  end

  def generate_budget
    BudgetGenerator.new(@trip).call
    redirect_to trip_path(@trip), notice: "Budget recalculated."
  end

  def destroy
    @trip.destroy
    redirect_to trips_path, notice: "Trip deleted."
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:id])
  end

  def trip_params
    params.require(:trip).permit(:name, :destination_city, :destination_country, :start_date, :end_date, :travelers_count, :currency)
  end

  def preference_params
    params.require(:trip_preference).permit(:lodging_style, :hotel_nights, :airbnb_nights, :fancy_restaurant_meals, :casual_restaurant_meals, :street_food_meals, :activities_count, :nightlife_nights, :shopping_budget_level, :overall_comfort_level, :notes)
  end
end

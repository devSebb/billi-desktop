class TripPreferencesController < ApplicationController
  before_action :authenticate_user!
  
  def update
    @trip = current_user.trips.find(params[:trip_id])
    @preference = @trip.trip_preference
    
    if @preference.update(preference_params)
      BudgetGenerator.new(@trip).call
      @budget = @trip.reload.trip_budget
      
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to trip_path(@trip) }
      end
    else
      head :unprocessable_entity
    end
  end

  private

  def preference_params
    params.require(:trip_preference).permit(:lodging_style, :hotel_nights, :airbnb_nights, :fancy_restaurant_meals, :casual_restaurant_meals, :street_food_meals, :activities_count, :nightlife_nights, :shopping_budget_level, :overall_comfort_level, :notes)
  end
end


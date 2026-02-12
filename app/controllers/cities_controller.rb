class CitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_city, only: [:show]

  def show
    @snapshot = CitySnapshotPicker.call(@city)
    @cost_rows = @snapshot ? CityCostPresenter.call(@snapshot) : []

    if @snapshot
      @data_badge = @snapshot.source == "traveltables" ? "Real data" : "Estimated"
      @updated_at = @snapshot.collected_at
      @currency_label = currency_label_for(@snapshot)
    end
  end

  private

  def set_city
    @city = City.find_by!(slug: params[:slug])
  end

  def currency_label_for(snapshot)
    return "Local currency (#{snapshot.currency})" unless current_user&.display_currency.present?

    if current_user.display_currency.upcase == (snapshot.currency || "USD").to_s.upcase
      "Local currency (#{snapshot.currency})"
    else
      "Converted to #{current_user.display_currency}"
    end
  end
end

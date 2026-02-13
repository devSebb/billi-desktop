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
    display_currency = current_user&.display_currency.presence || "USD"

    if display_currency.upcase == (snapshot.currency || "USD").to_s.upcase
      "Prices in #{display_currency.upcase}"
    else
      "Converted to #{display_currency.upcase}"
    end
  end
end

class DisplayCurrencyController < ApplicationController
  before_action :authenticate_user!

  ALLOWED_CURRENCIES = %w[USD EUR GBP BRL CHF].freeze

  def update
    currency = params[:display_currency].to_s.upcase
    if ALLOWED_CURRENCIES.include?(currency)
      current_user.update!(display_currency: currency)
    end
    redirect_back(fallback_location: root_path)
  end
end

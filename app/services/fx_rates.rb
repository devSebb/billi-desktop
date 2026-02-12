# v1: display-only FX. No historical accuracy. Rates are illustrative.
# If no rate exists, callers should show trip-currency amounts (no conversion).
class FxRates
  # Static rates to USD (base). To convert from USD to X: multiply by RATES[X].
  # To convert from X to Y: (amount_in_x / RATES[x]) * RATES[y] = amount_in_y
  # Simpler: from X to Y we use rate X->Y = RATES[Y] / RATES[X] (when base is USD).
  RATES_TO_USD = {
    "USD" => 1.0,
    "EUR" => 0.92,
    "GBP" => 0.79,
    "BRL" => 5.0
  }.freeze

  def self.get_rate(from_currency, to_currency)
    from = (from_currency || "USD").to_s.upcase
    to = (to_currency || "USD").to_s.upcase
    return 1.0 if from == to

    from_rate = RATES_TO_USD[from]
    to_rate = RATES_TO_USD[to]
    return nil unless from_rate && to_rate

    # amount_in_from * rate = amount_in_to  =>  rate = to_rate / from_rate (when base is USD)
    to_rate / from_rate
  end

  # Returns converted amount in display currency, or nil if rate unavailable.
  def self.convert(amount, from_currency, to_currency)
    rate = get_rate(from_currency, to_currency)
    return nil unless rate

    (amount.to_d * rate).to_f
  end
end
